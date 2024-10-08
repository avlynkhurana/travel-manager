import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';

import 'package:travel_manager/pages/add_trip.dart';
import 'package:travel_manager/pages/profile_page.dart'; // Import for File

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> trips = [];
  String? _userName;
  List<Map<String, dynamic>> filteredTrips = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _imagePath;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchTrips();
    _loadProfileImage();
  }

  void _loadUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      setState(() {
        _userName = userDoc.data()?['username'] ??
            user.displayName ??
            prefs.getString('username') ??
            'User';
      });
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    _imagePath = prefs.getString('profile_image');

    if (_imagePath != null && _imagePath!.isNotEmpty) {
      setState(() {
        _imageFile = File(_imagePath!);
      });
    }
  }

  Future<void> _fetchTrips() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final querySnapshot = await _firestore
            .collection('trips')
            .doc(user.uid)
            .collection('userTrips')
            .get();

        final fetchedTrips = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();

        if (!mounted) return;
        setState(() {
          trips =
              fetchedTrips.where((trip) => trip['deleted'] != true).toList();
          _updateUpcomingTrips();
          _sortTripsByStartDate();
          filteredTrips = List.from(trips);
        });
      } catch (e) {
        print("Error fetching trips: $e");
      }
    }
  }

  void addTrip(Map<String, dynamic> newTrip) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docRef = await _firestore
            .collection('trips')
            .doc(user.uid)
            .collection('userTrips')
            .add(newTrip);

        newTrip['id'] = docRef.id;

        if (!mounted) return;
        setState(() {
          trips.add(newTrip);
          _updateUpcomingTrips();
          _sortTripsByStartDate();
          filteredTrips = List.from(trips);
        });
      } catch (e) {
        print("Error adding trip: $e");
      }
    }
  }

  void updateTrip(int index, dynamic result) async {
    final user = _auth.currentUser;
    if (user != null && result is Map<String, dynamic>) {
      final tripId = trips[index]['id'];
      try {
        await _firestore
            .collection('trips')
            .doc(user.uid)
            .collection('userTrips')
            .doc(tripId)
            .update(result);

        if (!mounted) return;
        setState(() {
          trips[index] = {
            'id': tripId,
            ...result,
          };
          _updateUpcomingTrips();
          _sortTripsByStartDate();
          filteredTrips = List.from(trips);
        });
      } catch (e) {
        print("Error updating trip: $e");
      }
    } else if (result == 'delete') {
      final tripId = trips[index]['id'];
      try {
        await _firestore
            .collection('trips')
            .doc(user?.uid)
            .collection('userTrips')
            .doc(tripId)
            .update({'deleted': true});

        if (!mounted) return;
        setState(() {
          trips.removeAt(index);
          filteredTrips = List.from(trips);
        });
      } catch (e) {
        print("Error deleting trip: $e");
      }
    }
  }

  void _updateUpcomingTrips() {
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    for (var trip in trips) {
      if (trip['startDate'] != null) {
        DateTime startDate =
            DateTime.parse(trip['startDate'].split('-').reversed.join());

        if (todayWithoutTime.isAfter(startDate)) {
          trip['upcoming'] = false;
        } else {
          trip['upcoming'] = true;
        }
      }
    }
  }

  void _sortTripsByStartDate() {
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    trips.sort((a, b) {
      final aStartDate = a['startDate'];
      final bStartDate = b['startDate'];

      if (aStartDate != null && bStartDate != null) {
        DateTime dateA = DateTime.parse(aStartDate.split('-').reversed.join());
        DateTime dateB = DateTime.parse(bStartDate.split('-').reversed.join());

        return dateA.compareTo(dateB);
      } else {
        return 0;
      }
    });
  }

  void _filterTrips(String query) {
    final filtered = trips.where((trip) {
      final destinationLower = trip['destination']?.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return destinationLower.contains(queryLower);
    }).toList();

    if (!mounted) return;
    setState(() {
      filteredTrips = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : const AssetImage('default-profile.png') as ImageProvider,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Welcome, $_userName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (query) => _filterTrips(query),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search trips by destination',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _HomeButton(
                    icon: Icons.add,
                    label: 'Add Trip',
                    onTap: () async {
                      final newTrip = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTripPage(),
                        ),
                      );

                      if (newTrip != null) {
                        addTrip(newTrip);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _HomeButton(
                    icon: Icons.calendar_today,
                    label: 'Upcoming',
                    onTap: () {
                      // Logic for viewing upcoming trips
                    },
                  ),
                ),
                Expanded(
                  child: _HomeButton(
                    icon: Icons.manage_accounts,
                    label: 'Profile',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );

                      if (result == 'refresh') {
                        _loadUserName();
                        _loadProfileImage(); // Refresh profile image on return
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Upcoming Trips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
