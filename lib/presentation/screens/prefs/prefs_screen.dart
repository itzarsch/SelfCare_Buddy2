import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class PrefsScreen extends StatefulWidget {
  const PrefsScreen({super.key});

  @override
  State<PrefsScreen> createState() => _PrefsScreenState();
}

class _PrefsScreenState extends State<PrefsScreen> {
  bool _notificationsEnabled = true;

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Progress?'),
          content: const Text('Are you sure you want to reset all your progress? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Reset', style: TextStyle(color: Colors.red[800])),
              onPressed: () {
                // Here you would call a method to reset all user data
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress has been reset.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, 'Appearance'),
          _buildAppearanceSettings(context),
          const Divider(),
          _buildSectionTitle(context, 'Notifications'),
          _buildNotificationSettings(context),
          const Divider(),
          _buildSectionTitle(context, 'Data Management'),
          _buildResetProgress(context),
        ],
      ),
    );
  }

  Padding _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('Light Mode'),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeProvider.setThemeMode(value);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark Mode'),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeProvider.setThemeMode(value);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Follow System'),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) themeProvider.setThemeMode(value);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return SwitchListTile(
      title: const Text('Enable Reminders'),
      subtitle: const Text('Allow notifications for daily activities'),
      value: _notificationsEnabled,
      onChanged: (bool value) {
        setState(() {
          _notificationsEnabled = value;
          // You would also call a method here to globally set notification permissions
        });
      },
    );
  }

  Widget _buildResetProgress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[800],
          side: BorderSide(color: Colors.red[200]!),
        ),
        onPressed: _showResetConfirmationDialog,
        child: const Text('Reset All Progress'),
      ),
    );
  }
}
