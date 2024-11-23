import 'package:flutter/material.dart';

class HotelsPage extends StatelessWidget {
  const HotelsPage({super.key}); // Add const here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels'), // Add const here
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hotel Booking'), // Add const here
                content: const Text(
                    'Book a hotel functionality coming soon!'), // Add const here
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'), // Add const here
                  ),
                ],
              ),
            );
          },
          child: const Text('Book a Hotel'), // Add const here
        ),
      ),
    );
  }
}
