import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../domain/entities/daily_log.dart';
import '../../providers/selfcare_provider.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color _getColorForScore(int score) {
    if (score > 80) {
      return Colors.green.shade700; // Hijau Tua
    } else if (score > 50 && score <= 80) {
      return Colors.lightGreen.shade400; // Hijau Muda
    } else if (score > 0 && score <= 50) {
      return Colors.yellow.shade600; // Kuning
    } else {
      return Colors.transparent; // Tidak diberi warna
    }
  }

  Map<DateTime, int> _generateScoreMap(List<DailyLog> logs, int totalActivities) {
    final Map<DateTime, int> scoreMap = {};
    if (totalActivities == 0) return scoreMap;
    for (var log in logs) {
      final score = (log.completedActivities.length / totalActivities * 100).round();
      scoreMap[DateTime.utc(log.date.year, log.date.month, log.date.day)] = score;
    }
    return scoreMap;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelfCareProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.allLogs.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Your Journey'), centerTitle: true),
            body: _buildEmptyState(),
          );
        }

        final scoreMap = _generateScoreMap(provider.allLogs, provider.totalActivities);

        return Scaffold(
          appBar: AppBar(title: const Text('Your Journey'), centerTitle: true),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Progress', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _buildProgressChart(scoreMap),
                  const SizedBox(height: 24),
                  Text('Monthly Overview', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _buildMonthlyCalendar(scoreMap),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 80, color: Theme.of(context).textTheme.bodyMedium?.color),
            const SizedBox(height: 24),
            Text('No Journey Data Yet', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Complete activities on the Home screen to see your progress here.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(Map<DateTime, int> scores) {
    final List<FlSpot> spots = [];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final dayUtc = DateTime.utc(day.year, day.month, day.day);
      final score = scores[dayUtc] ?? 0;
      spots.add(FlSpot(6.0 - i, score.toDouble()));
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(top: 24, right: 24, bottom: 12, left: 12),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 20)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                      return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('${day.day}/${day.month}'));
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: Theme.of(context).primaryColor.withAlpha(77)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendar(Map<DateTime, int> scores) {
    final headerStyle = HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      titleTextStyle: Theme.of(context).textTheme.titleLarge ?? const TextStyle(),
    );
    final daysOfWeekStyle = DaysOfWeekStyle(
      weekdayStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      weekendStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
    );

    return Card(
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        headerStyle: headerStyle,
        daysOfWeekStyle: daysOfWeekStyle,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final score = scores[DateTime.utc(day.year, day.month, day.day)] ?? 0;
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(color: _getColorForScore(score), shape: BoxShape.circle),
              child: Center(child: Text('${day.day}', style: TextStyle(color: score > 0 ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color))),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            final score = scores[DateTime.utc(day.year, day.month, day.day)] ?? 0;
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: _getColorForScore(score),
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
              ),
              child: Center(child: Text('${day.day}', style: TextStyle(color: score > 0 ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color))),
            );
          },
        ),
      ),
    );
  }
}
