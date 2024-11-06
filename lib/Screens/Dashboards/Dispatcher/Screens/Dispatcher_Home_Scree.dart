import 'package:flutter/material.dart';

class DispatcherHomeScreen extends StatelessWidget {
  final Map<String, dynamic> userProfileData;

  const DispatcherHomeScreen({super.key, required this.userProfileData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatcher Home'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${userProfileData['name'] ?? 'Dispatcher'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Here are your tasks for today:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

          ],
        ),
      ),
    );
  }
}
