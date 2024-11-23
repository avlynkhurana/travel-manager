import 'package:flutter/material.dart';

class HomestaysPage extends StatelessWidget {
  const HomestaysPage({super.key}); // Add const here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homestays'), // Add const here
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Homestay Booking'), // Add const here
                content: const Text(
                    'Book a homestay functionality coming soon!'), // Add const here
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'), // Add const here
                  ),
                ],
              ),
            );
          },
          child: const Text('Book a Homestay'), // Add const here
        ),
      ),
    );
  }
}
