import 'dart:math';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../providers/selfcare_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../domain/entities/activity.dart' as domain;

// UI-specific data model for an activity
class _Activity {
  final String id;
  final String title;
  final String recommendation;
  final String interactionType;
  final IconData icon;
  final int? targetValue;

  int currentValue;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String status;

  _Activity({
    required this.id,
    required this.title,
    required this.recommendation,
    required this.interactionType,
    required this.icon,
    this.targetValue,
    this.currentValue = 0,
    this.status = 'WAITING...',
  });

  bool isCompleted() {
    if (interactionType == 'increment') {
      return currentValue >= (targetValue ?? 1);
    }
    if (interactionType == 'log_time_range') {
      return status == 'Selesai';
    }
    return false;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _motivationalQuotes = [
    "The secret of getting ahead is getting started.",
    "Your only limit is your mind.",
    "Push yourself, because no one else is going to do it for you.",
    "Great things never come from comfort zones.",
    "The harder you work for something, the greater you'll feel when you achieve it."
  ];

  late String _currentQuote;
  List<_Activity> _activities = []; // Ubah dari late final ke list biasa
  bool _isActivitiesInitialized = false;
  int _lastResetCounter = 0; // Track reset counter

  @override
  void initState() {
    super.initState();
    _currentQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
  }

  // Method to reset activities (dipanggil dari luar jika perlu)
  void resetActivities() {
    setState(() {
      _isActivitiesInitialized = false;
    });
  }

  void _initializeActivities(BuildContext context) {
    final provider = Provider.of<SelfCareProvider>(context, listen: false);
    
    debugPrint('HomeScreen: _initializeActivities called, _isActivitiesInitialized: $_isActivitiesInitialized, provider.resetCounter: ${provider.resetCounter}, _lastResetCounter: $_lastResetCounter');
    
    // Check if reset counter has changed
    if (_isActivitiesInitialized && provider.resetCounter != _lastResetCounter) {
      debugPrint('HomeScreen: Reset detected in _initializeActivities, reinitializing...');
      _isActivitiesInitialized = false;
    }
    
    _lastResetCounter = provider.resetCounter;
    
    if (_isActivitiesInitialized) {
      debugPrint('HomeScreen: Activities already initialized, skipping');
      return;
    }

    debugPrint('HomeScreen: Initializing activities...');
    _activities = provider.activities.map((domain.Activity domainActivity) {
      final isCompleted = provider.isActivityCompleted(domainActivity.id);
      String interactionType;
      int? targetValue;
      switch (domainActivity.type) {
        case domain.ActivityType.water:
        case domain.ActivityType.food:
          interactionType = 'increment';
          targetValue = (domainActivity.type == domain.ActivityType.water) ? 8 : 3;
          break;
        case domain.ActivityType.sleep:
        case domain.ActivityType.exercise:
        case domain.ActivityType.meTime:
          interactionType = 'log_time_range';
          break;
      }
      return _Activity(
        id: domainActivity.id,
        title: domainActivity.name,
        recommendation: domainActivity.description,
        icon: domainActivity.icon,
        interactionType: interactionType,
        targetValue: targetValue,
        status: isCompleted ? 'Selesai' : 'WAITING...',
        currentValue: isCompleted ? (targetValue ?? 1) : 0,
      );
    }).toList();
    _isActivitiesInitialized = true;
  }

  void _syncWithProvider(_Activity activity, SelfCareProvider provider) {
    final bool localState = activity.isCompleted();
    final bool providerState = provider.isActivityCompleted(activity.id);
    if (localState != providerState) {
      provider.toggleActivity(activity.id);
    }
  }

  double _calculateCompletionPercentage() {
    if (!_isActivitiesInitialized || _activities.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    
    for (var activity in _activities) {
      if (activity.interactionType == 'increment' && activity.targetValue != null) {
        // Untuk aktivitas increment, hitung progress parsial
        final progress = (activity.currentValue / activity.targetValue!).clamp(0.0, 1.0);
        totalProgress += progress;
      } else {
        // Untuk aktivitas lain, hitung 0 atau 1 (completed atau belum)
        totalProgress += activity.isCompleted() ? 1.0 : 0.0;
      }
    }
    
    return totalProgress / _activities.length;
  }

  Future<void> _selectTime(BuildContext context, _Activity activity, bool isStartTime, SelfCareProvider provider) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          activity.startTime = picked;
        } else {
          activity.endTime = picked;
        }
        _syncWithProvider(activity, provider);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<SelfCareProvider, SettingsProvider>(
      builder: (context, selfCareProvider, settingsProvider, child) {
        // Check for reset inside Consumer to detect changes
        if (_isActivitiesInitialized && selfCareProvider.resetCounter != _lastResetCounter) {
          debugPrint('HomeScreen: Reset detected in Consumer, old: $_lastResetCounter, new: ${selfCareProvider.resetCounter}');
          _lastResetCounter = selfCareProvider.resetCounter;
          _isActivitiesInitialized = false;
        }
        
        // Initialize or reinitialize activities
        _initializeActivities(context);
        
        return Scaffold(
          appBar: AppBar(title: const Text('Selfcare Buddy')),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How are you feeling, friend?', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: double.infinity,
                    child: Text('"$_currentQuote"', style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24.0),
                  _buildStreakIndicator(selfCareProvider.streak, theme),
                  const SizedBox(height: 24.0),
                  Text('Daily Activities', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16.0),
                  Column(
                    children: [
                      for (int i = 0; i < _activities.length; i++) ...[
                        _buildActivityItem(_activities[i], selfCareProvider, settingsProvider, theme),
                        if (i < _activities.length - 1) const SizedBox(height: 12.0),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakIndicator(int streakCount, ThemeData theme) {
    final percentage = _calculateCompletionPercentage();
    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: AppColors.warning, size: 40),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$streakCount Days', style: theme.textTheme.headlineMedium),
                  Text('Your current streak!', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          SizedBox(height: 50, child: VerticalDivider(thickness: 1.5, color: theme.dividerColor.withAlpha(77))),
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            animation: true,
            percent: percentage,
            center: Text('${(percentage * 100).toStringAsFixed(0)}%', style: theme.textTheme.titleLarge),
            footer: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Daily Goal', style: theme.textTheme.bodyMedium),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withAlpha(51),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(_Activity activity, SelfCareProvider selfCareProvider, SettingsProvider settingsProvider, ThemeData theme) {
    final notificationIcon = IconButton(
      icon: Icon(settingsProvider.notificationsEnabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined),
      color: settingsProvider.notificationsEnabled ? theme.colorScheme.primary : theme.disabledColor,
      onPressed: settingsProvider.notificationsEnabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reminder for ${activity.title} configured!'), duration: const Duration(seconds: 1)),
              );
            }
          : null,
    );

    switch (activity.interactionType) {
      case 'increment':
        return GlassmorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(activity.icon, color: theme.colorScheme.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.title, style: theme.textTheme.titleLarge),
                    Text(activity.recommendation, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (activity.currentValue > 0)
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(Icons.refresh),
                          color: theme.colorScheme.error,
                          tooltip: 'Reset',
                          onPressed: () => setState(() {
                            activity.currentValue = 0;
                            _syncWithProvider(activity, selfCareProvider);
                          }),
                        ),
                      )
                    else
                      const SizedBox(width: 40),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: notificationIcon,
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: theme.textTheme.bodyMedium?.color),
                        onPressed: () => setState(() {
                          if (activity.currentValue > 0) activity.currentValue--;
                          _syncWithProvider(activity, selfCareProvider);
                        }),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(child: Text('${activity.currentValue}/${activity.targetValue}', style: theme.textTheme.titleSmall)),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        icon: Icon(Icons.add_circle_outline, color: theme.textTheme.bodyMedium?.color),
                        onPressed: () => setState(() {
                          activity.currentValue++;
                          _syncWithProvider(activity, selfCareProvider);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'log_time_range':
        bool isCompleted = activity.isCompleted();
        bool canLog = activity.startTime != null && activity.endTime != null && !isCompleted;
        return GlassmorphicContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activity.title, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(activity.recommendation, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCompleted || activity.startTime != null || activity.endTime != null)
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            icon: const Icon(Icons.refresh),
                            color: theme.colorScheme.error,
                            tooltip: 'Reset',
                            onPressed: () => setState(() {
                              activity.startTime = null;
                              activity.endTime = null;
                              activity.status = 'WAITING...';
                              _syncWithProvider(activity, selfCareProvider);
                            }),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: notificationIcon,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimePickerButton(context, 'Start Time', activity.startTime, () => _selectTime(context, activity, true, selfCareProvider), theme),
                  _buildTimePickerButton(context, 'End Time', activity.endTime, () => _selectTime(context, activity, false, selfCareProvider), theme),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status: ${activity.status}', style: TextStyle(color: isCompleted ? AppColors.success : AppColors.warning, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: canLog ? () => setState(() {
                      activity.status = 'Selesai';
                      _syncWithProvider(activity, selfCareProvider);
                    }) : null,
                    child: const Text('LOG IT'),
                  ),
                ],
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTimePickerButton(BuildContext context, String label, TimeOfDay? time, VoidCallback onPressed, ThemeData theme) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
          onPressed: onPressed,
          child: Text(time?.format(context) ?? 'Select', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

