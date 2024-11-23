import 'package:flutter/material.dart';

class HolidayPackagesPage extends StatelessWidget {
  const HolidayPackagesPage({super.key}); // Add const here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holiday Packages'), // Add const here
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Holiday Packages'), // Add const here
                content: const Text(
                    'Explore holiday packages functionality coming soon!'), // Add const here
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'), // Add const here
                  ),
                ],
              ),
            );
          },
          child: const Text('Explore Packages'), // Add const here
        ),
      ),
    );
  }
}
