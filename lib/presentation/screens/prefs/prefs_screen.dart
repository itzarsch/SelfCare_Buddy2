import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../providers/theme_provider.dart';
import '../../providers/selfcare_provider.dart';
import '../../providers/settings_provider.dart';

class PrefsScreen extends StatefulWidget {
  const PrefsScreen({super.key});

  @override
  State<PrefsScreen> createState() => _PrefsScreenState();
}

class _PrefsScreenState extends State<PrefsScreen> {

  void _showResetConfirmationDialog() async {
    final provider = Provider.of<SelfCareProvider>(context, listen: false);
    
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(204), // 80% opacity
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Reset Progress?', style: Theme.of(context).textTheme.headlineSmall),
          content: Text('Are you sure you want to reset all your progress? This action cannot be undone.', style: Theme.of(context).textTheme.bodyMedium),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Reset', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await provider.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress has been reset.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAppearanceSettings(context),
              _buildNotificationSettings(context),
              _buildResetProgress(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('Light Mode'),
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (ThemeMode? value) => value != null ? themeProvider.setThemeMode(value) : null,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark Mode'),
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (ThemeMode? value) => value != null ? themeProvider.setThemeMode(value) : null,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Follow System'),
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (ThemeMode? value) => value != null ? themeProvider.setThemeMode(value) : null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Notifications'),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return SwitchListTile(
                title: const Text('Enable Reminders'),
                subtitle: const Text('Allow notifications for daily activities'),
                value: settingsProvider.notificationsEnabled,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                onChanged: (bool value) => settingsProvider.setNotificationsEnabled(value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResetProgress(BuildContext context) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _buildSectionTitle(context, 'Data Management'),
          Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error.withAlpha(128)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
              ),
              onPressed: _showResetConfirmationDialog,
              child: const Text('Reset All Progress'),
            ),
          ),
        ],
      ),
    );
  }
}
