import 'package:flutter/material.dart';

class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight'),
      ),
      body: const Center(
        child: Text(
          'Weight tracking will go here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}