import 'package:flutter/material.dart';

class TrainsPage extends StatelessWidget {
  // Add const to the constructor
  const TrainsPage({super.key}); // 'const' constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Trains'), // const used here as it's a constant string
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Train Booking'), // const used here
                content: const Text(
                    'Book a train ticket functionality coming soon!'), // const used here
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'), // const used here
                  ),
                ],
              ),
            );
          },
          child: const Text('Book a Train'), // const used here
        ),
      ),
    );
  }
}
