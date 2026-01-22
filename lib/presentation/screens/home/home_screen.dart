import 'dart:math';
import 'package:flutter/material.dart';

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
  int _streakCount = 5; // Dummy streak count

  // Dummy state for activities
  final Map<String, bool> _activityCompletion = {
    'Water Intake': false,
    'Meals': false,
    'Restful Sleep': false,
    'Exercise': false,
    'Self Reflection': false,
  };

  @override
  void initState() {
    super.initState();
    _currentQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selfcare Buddy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'How are you feeling, friend?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),

              // Motivational Quote
              Text(
                '"$_currentQuote"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              // Streak Indicator
              _buildStreakIndicator(),
              const SizedBox(height: 24.0),

              // Daily Activities
              Text(
                'Daily Activities',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              _buildActivityList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakIndicator() {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_streakCount Days',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Your current streak!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        _buildActivityItem(
          title: 'Water Intake',
          recommendation: 'Recommended: 8 glasses',
          interactionType: 'increment',
        ),
        _buildActivityItem(
          title: 'Meals',
          recommendation: 'Recommended: 3 balanced meals',
          interactionType: 'increment',
        ),
        _buildActivityItem(
          title: 'Restful Sleep',
          recommendation: 'Recommended: 7-9 hours',
          interactionType: 'time_range',
        ),
        _buildActivityItem(
          title: 'Exercise',
          recommendation: 'Recommended: 30 minutes',
          interactionType: 'time_range',
        ),
        _buildActivityItem(
          title: 'Self Reflection',
          recommendation: 'Take a moment for yourself',
          interactionType: 'check',
        ),
      ],
    );
  }

  Widget _buildActivityItem({required String title, required String recommendation, required String interactionType}) {
    // This function would be expanded with real logic
    void handleInteraction() {
      // Logic for time pickers, increments, etc. would go here.
      // For now, we'll just toggle the completion state for demo purposes.
      setState(() {
        _activityCompletion[title] = !_activityCompletion[title]!;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$title interaction!'),
        duration: const Duration(seconds: 1),
      ));
    }

    Widget buildTrailing() {
      Widget interactionWidget;
      switch (interactionType) {
        case 'increment':
          interactionWidget = IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: handleInteraction,
            tooltip: 'Log an entry',
          );
          break;
        case 'time_range':
          interactionWidget = TextButton(
            child: const Text('LOG TIME'),
            onPressed: handleInteraction,
          );
          break;
        default: // 'check'
          interactionWidget = const SizedBox.shrink(); // Checkbox is the main interaction
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          interactionWidget,
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Set reminder for $title'),
                duration: const Duration(seconds: 1),
              ));
            },
            tooltip: 'Set Reminder',
          ),
        ],
      );
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Checkbox(
          value: _activityCompletion[title],
          onChanged: (bool? value) {
            setState(() {
              _activityCompletion[title] = value ?? false;
            });
          },
        ),
        title: Text(title),
        subtitle: Text(recommendation),
        trailing: buildTrailing(),
      ),
    );
  }
}
