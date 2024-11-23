import 'package:flutter/material.dart';

class InsurancePage extends StatelessWidget {
  const InsurancePage({super.key}); // Add const here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance'), // Add const here
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Travel Insurance'), // Add const here
                content: const Text(
                    'Travel insurance functionality coming soon!'), // Add const here
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'), // Add const here
                  ),
                ],
              ),
            );
          },
          child: const Text('Buy Insurance'), // Add const here
        ),
      ),
    );
  }
}
