import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewTravelPlanPage extends StatefulWidget {
  final Map<String, dynamic> travelPlan;
  final int index;

  const ViewTravelPlanPage({
    required this.travelPlan,
    required this.index,
    super.key,
  });

  @override
  _ViewTravelPlanPageState createState() => _ViewTravelPlanPageState();
}

class _ViewTravelPlanPageState extends State<ViewTravelPlanPage> {
  final _formKey = GlobalKey<FormState>();
  late String _destination;
  late String _travelDate;
  late String _returnDate;
  late String _notes;

  TextEditingController _travelDateController = TextEditingController();
  TextEditingController _returnDateController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _destination = widget.travelPlan['destination'] ?? '';
    _travelDate = widget.travelPlan['travelDate'] ?? '';
    _returnDate = widget.travelPlan['returnDate'] ?? '';
    _notes = widget.travelPlan['notes'] ?? '';

    _travelDateController.text =
        _travelDate; // Initialize travel date controller
    _returnDateController.text =
        _returnDate; // Initialize return date controller
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTravelPlan = {
        'id': widget.travelPlan['id'], // Ensure 'id' is included
        'destination': _destination,
        'travelDate': _travelDate,
        'returnDate': _returnDate,
        'notes': _notes,
      };

      Navigator.pop(context, updatedTravelPlan);
    }
  }

  Future<void> _deleteTravelPlan() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final travelPlanId =
            widget.travelPlan['id']; // Ensure this field exists

        if (travelPlanId != null) {
          // Mark the travel plan as deleted in Firebase instead of removing it
          await _firestore
              .collection('travelPlans')
              .doc(user.uid)
              .collection('userTravelPlans')
              .doc(travelPlanId)
              .update({'deleted': true}); // Add a 'deleted' flag

          Navigator.pop(context, 'delete');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid travel plan ID found.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete travel plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickTravelDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _travelDate =
            '${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}';
        _travelDateController.text = _travelDate; // Update date text field
      });
    }
  }

  Future<void> _pickReturnDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _returnDate =
            '${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}';
        _returnDateController.text = _returnDate; // Update date text field
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Planner'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context, 'cancel'); // Return 'cancel' when back is pressed
          },
        ),
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05), // Dynamic padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Travel Plan Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _destination,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the destination';
                  }
                  return null;
                },
                onSaved: (value) {
                  _destination = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _travelDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Travel Date (DD-MM-YYYY)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onTap: _pickTravelDate,
                onSaved: (value) {
                  _travelDate = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _returnDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Return Date (DD-MM-YYYY)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onTap: _pickReturnDate,
                onSaved: (value) {
                  _returnDate = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onSaved: (value) {
                  _notes = value!;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _deleteTravelPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Delete Travel Plan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
