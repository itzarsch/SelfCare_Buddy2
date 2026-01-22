import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';

// Dummy data structure for daily scores
class DailyScore {
  final DateTime date;
  final int score;

  DailyScore(this.date, this.score);
}

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  // Generate dummy data for the last 30 days
  final Map<DateTime, int> _scores = {
    for (int i = 0; i < 30; i++)
      DateTime.now().subtract(Duration(days: i)): [0, 20, 40, 60, 80, 100][Random().nextInt(6)]
  };

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color _getColorForScore(int score) {
    if (score >= 80) {
      return Colors.green.shade700; // Dark Green
    } else if (score >= 40) {
      return Colors.green.shade300; // Light Green
    } else if (score > 0) {
      return Colors.orange.shade300; // Orange
    } else {
      return Colors.white; // White for no activity
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Journey'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Progress',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildProgressChart(),
              const SizedBox(height: 24),
              Text(
                'Monthly Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildMonthlyCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    // Prepare data for the chart (last 7 days)
    final List<FlSpot> spots = [];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      // Normalize date for chart mapping
      final score = _scores.entries
          .firstWhere((entry) => isSameDay(entry.key, day), orElse: () => MapEntry(day, 0))
          .value;
      spots.add(FlSpot(6.0 - i, score.toDouble()));
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.only(top: 24, right: 24, bottom: 12),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(
                    color: Colors.black12,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return const FlLine(
                    color: Colors.black12,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 20,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                       final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                       return Padding(
                         padding: const EdgeInsets.only(top: 8.0),
                         child: Text('${day.day}/${day.month}'),
                       );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
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
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay; // update `_focusedDay` here as well
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final score = _scores.entries
                .firstWhere((entry) => isSameDay(entry.key, day), orElse: () => MapEntry(day, 0))
                .value;
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: _getColorForScore(score),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: score > 0 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            final score = _scores.entries
                .firstWhere((entry) => isSameDay(entry.key, day), orElse: () => MapEntry(day, 0))
                .value;
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: _getColorForScore(score),
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: score > 0 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
