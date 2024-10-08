import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  _AddTripPageState createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  String _tripName = '';
  double _budget = 0.0;
  String _startDate = '';
  String _endDate = '';
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> addTrip(Map<String, dynamic> tripData) async {
    try {
      // Reference to the 'trips' collection in Firestore
      CollectionReference trips =
          FirebaseFirestore.instance.collection('trips');

      // Add the new trip document
      await trips.add(tripData);

      // Show success message or perform other actions after saving
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save trip: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Trip'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTripNameField(),
                const SizedBox(height: 16),
                _buildBudgetField(),
                const SizedBox(height: 16),
                _buildStartDateField(context),
                const SizedBox(height: 16),
                _buildEndDateField(context),
                const SizedBox(height: 16),
                _buildNotesField(),
                const SizedBox(height: 16),
                _buildSaveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Trip Name',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the trip name';
        }
        return null;
      },
      onSaved: (value) {
        _tripName = value!;
      },
    );
  }

  Widget _buildBudgetField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Budget',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the budget';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid budget (e.g., 1000.00)';
        }
        return null;
      },
      onSaved: (value) {
        _budget = double.parse(value!);
      },
    );
  }

  Widget _buildStartDateField(BuildContext context) {
    return TextFormField(
      controller: _startDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Start Date (DD-MM-YYYY)',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          setState(() {
            _startDate = DateFormat('dd-MM-yyyy').format(pickedDate);
            _startDateController.text = _startDate;
          });
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the start date';
        }
        return null;
      },
      onSaved: (value) {
        _startDate = value!;
      },
    );
  }

  Widget _buildEndDateField(BuildContext context) {
    return TextFormField(
      controller: _endDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'End Date (DD-MM-YYYY)',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          setState(() {
            _endDate = DateFormat('dd-MM-yyyy').format(pickedDate);
            _endDateController.text = _endDate;
          });
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the end date';
        }
        return null;
      },
      onSaved: (value) {
        _endDate = value!;
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Notes (e.g., places to visit, trip details)',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onSaved: (value) {
        _notes = value ?? '';
      },
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            final newTrip = <String, dynamic>{
              'tripName': _tripName,
              'budget': _budget.toStringAsFixed(2),
              'startDate': _startDate,
              'endDate': _endDate,
              'notes': _notes,
            };

            // Call the addTrip function to save the trip data in Firestore
            addTrip(newTrip);

            // Return to the previous screen with the new trip data
            Navigator.pop(context, newTrip);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: const Text(
          'Save Trip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
