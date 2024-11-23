import 'package:flutter/material.dart';

class FlightsPage extends StatelessWidget {
  const FlightsPage({super.key}); // Add const here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flights'), // Add const here
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Flight Booking'), // Add const here
                content: const Text(
                    'Book a flight ticket functionality coming soon!'), // Add const here
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'), // Add const here
                  ),
                ],
              ),
            );
          },
          child: const Text('Book a Flight'), // Add const here
        ),
      ),
    );
  }
}
