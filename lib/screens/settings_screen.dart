import 'package:flutter/material.dart';
import 'package:meal_of_record/widgets/screen_background.dart';
import 'package:meal_of_record/config/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.blue),
            title: const Text('Data Management'),
            subtitle: const Text('Backup and restore your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.dataManagementRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2, color: Colors.orange),
            title: const Text('Containers'),
            subtitle: const Text('Manage tare weights and cookware'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.containerSettingsRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.track_changes, color: Colors.green),
            title: const Text('Goals & Targets'),
            subtitle: const Text('Configure calorie and macro targets'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.goalSettingsRoute);
            },
          ),
        ],
      ),
    );
  }
}
