import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/log_screen.dart';
import 'screens/weight_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free Cal Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    LogScreen(),
    WeightScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Reset to safe value on initialization
    _selectedIndex = 0;
  }

  void _onItemTapped(int index) {
    // Ensure the index is within valid bounds
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // Debug: log invalid index attempts
      print('Invalid tab index attempted: $index, valid range: 0-${_screens.length - 1}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure _selectedIndex is within valid bounds
    if (_selectedIndex >= _screens.length) {
      print('Resetting invalid _selectedIndex from $_selectedIndex to 0');
      _selectedIndex = 0;
    }
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight),
            label: 'Weight',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}