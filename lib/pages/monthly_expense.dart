import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonthlyTravelExpensePage extends StatefulWidget {
  final List<Map<String, dynamic>> trips;

  const MonthlyTravelExpensePage({required this.trips, super.key});

  @override
  _MonthlyTravelExpensePageState createState() =>
      _MonthlyTravelExpensePageState();
}

class _MonthlyTravelExpensePageState extends State<MonthlyTravelExpensePage> {
  Map<int, Map<String, dynamic>> _expectedExpenses = {};
  Map<int, Map<String, dynamic>> _currentExpenses = {};
  int _currentYear = DateTime.now().year;
  bool _showCurrentExpenses = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeExpenses();
  }

  Future<void> _initializeExpenses() async {
    await _fetchExpenseHistoryFromFirebase();
    await _calculateExpenses();
  }

  Future<void> _fetchExpenseHistoryFromFirebase() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('travelExpenseHistory')
            .where('year', isEqualTo: _currentYear)
            .get();

        Map<int, Map<String, dynamic>> fetchedExpenses = {};

        // Populate fetchedExpenses with data from Firebase
        for (var doc in snapshot.docs) {
          int month = doc.data()['month'] ?? 0;
          double total = doc.data()['total'] ?? 0.0;
          List trips = doc.data()['trips'] ?? [];

          fetchedExpenses[month] = {
            'total': total,
            'trips': trips,
          };
        }

        // Initialize all months for the current year
        for (int month = 1; month <= 12; month++) {
          if (!fetchedExpenses.containsKey(month)) {
            fetchedExpenses[month] = {'total': 0.0, 'trips': []};
          }
        }

        setState(() {
          _currentExpenses = fetchedExpenses;
        });
      } catch (e) {
        print('Error fetching expense history from Firebase: $e');
      }
    } else {
      print('User is not logged in.');
    }
  }

  Future<void> _calculateExpenses() async {
    Map<int, Map<String, dynamic>> expectedExpenses = {};
    Map<int, Map<String, dynamic>> currentExpenses = {};

    // Initialize expenses for each month (1-12)
    for (int month = 1; month <= 12; month++) {
      expectedExpenses[month] = {'total': 0.0, 'trips': []};
      currentExpenses[month] = _currentExpenses.containsKey(month)
          ? _currentExpenses[month]!
          : {'total': 0.0, 'trips': []};
    }

    DateTime todayWithoutTime =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int currentMonth = DateTime.now().month;

    for (var trip in widget.trips) {
      String startDateStr = trip['startDate']!;
      DateTime startDate = DateFormat('dd-MM-yyyy').parse(startDateStr);
      double cost = double.tryParse(trip['cost'] ?? '0') ?? 0.0;
      String tripName = trip['name'] ?? 'Unnamed Trip';

      // Add trip costs to the current or expected month
      if (startDate.year == _currentYear) {
        if (startDate.isBefore(todayWithoutTime) ||
            startDate.isAtSameMomentAs(todayWithoutTime)) {
          currentExpenses[startDate.month]!['total'] += cost;
          currentExpenses[startDate.month]!['trips'].add({
            'name': tripName,
            'cost': cost.toStringAsFixed(2),
          });
        } else if (startDate.isAfter(todayWithoutTime)) {
          expectedExpenses[startDate.month]!['total'] += cost;
          expectedExpenses[startDate.month]!['trips'].add({
            'name': tripName,
            'cost': cost.toStringAsFixed(2),
          });
        }
      }
    }

    // Ensure that every month is initialized in both expected and current expenses
    for (int month = 1; month <= 12; month++) {
      if (!_currentExpenses.containsKey(month)) {
        _currentExpenses[month] = {'total': 0.0, 'trips': []};
      }
    }

    setState(() {
      _currentExpenses = currentExpenses;

      // Merge current and expected trips for the current month
      if (expectedExpenses.containsKey(currentMonth)) {
        expectedExpenses[currentMonth]!['total'] +=
            currentExpenses[currentMonth]!['total'];
        expectedExpenses[currentMonth]!['trips']
            .addAll(currentExpenses[currentMonth]!['trips']);
      }

      _expectedExpenses = expectedExpenses;
    });
  }

  void _changeYear(int offset) {
    setState(() {
      _currentYear += offset;
      _initializeExpenses();
    });
  }

  double _calculateTotalYearlyExpense(Map<int, Map<String, dynamic>> expenses) {
    return expenses.values
        .map((monthData) => monthData['total'] as double)
        .fold(0.0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    Map<int, Map<String, dynamic>> displayedExpenses =
        _showCurrentExpenses ? _currentExpenses : _expectedExpenses;

    double yearlyTotal = _calculateTotalYearlyExpense(displayedExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Travel Expenses'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => _changeYear(-1),
          ),
          Center(
            child: Text(
              '$_currentYear',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            onPressed: () => _changeYear(1),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCurrentExpenses = true;
                    });
                  },
                  child: Text(
                    'Current',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _showCurrentExpenses ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCurrentExpenses = false;
                    });
                  },
                  child: Text(
                    'Expected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !_showCurrentExpenses ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: displayedExpenses.entries.map((entry) {
                  int month = entry.key;
                  double total = entry.value['total'];
                  List trips = entry.value['trips'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      color: Colors.grey[300],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.MMMM().format(DateTime(0, month)),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...trips.map<Widget>((trip) {
                              return ListTile(
                                title: Text(trip['name']),
                                trailing: Text('${trip['cost']}'),
                              );
                            }).toList(),
                            const Divider(),
                            ListTile(
                              title: const Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Text('${total.toStringAsFixed(2)}'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text(
                'Yearly Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text('${yearlyTotal.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}
