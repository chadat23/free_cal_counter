import 'package:flutter/material.dart';

class HorizontalBarChart extends StatelessWidget {
  final String character;
  final int currentValue;
  final int maxValue;
  final Color barColor;

  const HorizontalBarChart({
    super.key,
    required this.character,
    required this.currentValue,
    required this.maxValue,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage (0.0 to 1.0)
    final double percentage = maxValue > 0 ? (currentValue / maxValue).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      children: [
        // Horizontal bar chart
        Container(
          height: 4, // Much shorter - about 1mm
          width: 80, // Reduced width to fit 4 across screen
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 200, 200, 200), // Background track color
            borderRadius: BorderRadius.circular(2), // Much smaller radius
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 4,
              width: 80 * percentage,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2), // Much smaller radius
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Text display: "char num1/num2"
        Text(
          '$character $currentValue/$maxValue',
          style: const TextStyle(
            fontSize: 10, // Slightly smaller text
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

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
          // Horizontal bar charts section (stays at top)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                HorizontalBarChart(
                  character: '🔥',
                  currentValue: 2000,
                  maxValue: 3000,
                  barColor: Colors.blue,
                ),
                HorizontalBarChart(
                  character: 'P',
                  currentValue: 125,
                  maxValue: 160,
                  barColor: Colors.red,
                ),
                HorizontalBarChart(
                  character: 'F',
                  currentValue: 45,
                  maxValue: 88,
                  barColor: Colors.yellow,
                ),
                HorizontalBarChart(
                  character: 'C',
                  currentValue: 100,
                  maxValue: 225,
                  barColor: Colors.green,
                ),
              ],
            ),
          ),
          // Scrollable content below
          Expanded(
            child: SingleChildScrollView(
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Food logging will go here',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}