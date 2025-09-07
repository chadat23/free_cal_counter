import 'package:flutter/material.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  DateTime _currentDate = DateTime.now();

  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow';
    } else {
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      final dayOfWeek = days[date.weekday % 7];
      final month = months[date.month - 1];
      final day = date.day;
      
      return '$dayOfWeek, $month $day';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header with date navigation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous day button
                  IconButton(
                    onPressed: _previousDay,
                    icon: const Icon(Icons.chevron_left),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: const CircleBorder(),
                    ),
                  ),
                  // Date display
                  Text(
                    _formatDate(_currentDate),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Next day button
                  IconButton(
                    onPressed: _nextDay,
                    icon: const Icon(Icons.chevron_right),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Food logging will go here',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}