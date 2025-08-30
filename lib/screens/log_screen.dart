import 'package:flutter/material.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Log'),
      ),
      body: const Center(
        child: Text(
          'Food logging will go here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}