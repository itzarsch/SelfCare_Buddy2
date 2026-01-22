import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/daily_log.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/selfcare_provider.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Refresh data saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SelfCareProvider>(context, listen: false);
      provider.refresh();
      debugPrint('Journey Screen: Data refreshed. Total logs: ${provider.allLogs.length}');
    });
  }

  Color _getColorForScore(int score) {
    if (score >= 80) {
      return Colors.green.shade700; // Hijau Tua - Excellent
    } else if (score >= 60) {
      return Colors.lightGreen.shade400; // Hijau Muda - Good
    } else if (score >= 40) {
      return Colors.orange.shade400; // Orange - Fair
    } else if (score > 0) {
      return Colors.red.shade300; // Merah - Needs Improvement
    } else {
      return Colors.grey.shade200; // Abu-abu - No Data
    }
  }

  Map<DateTime, int> _generateScoreMap(List<DailyLog> logs, int totalActivities) {
    final Map<DateTime, int> scoreMap = {};
    if (totalActivities == 0) return scoreMap;
    for (var log in logs) {
      final score = (log.completedActivities.length / totalActivities * 100).round();
      scoreMap[DateTime.utc(log.date.year, log.date.month, log.date.day)] = score;
      debugPrint('Journey: Date ${log.date} - Score: $score% (${log.completedActivities.length}/$totalActivities)');
    }
    return scoreMap;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelfCareProvider>(
      builder: (context, provider, child) {
        debugPrint('Journey Screen: Building with ${provider.allLogs.length} logs');
        
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (provider.allLogs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Perjalanan Saya'),
              centerTitle: true,
            ),
            body: _buildEmptyState(),
          );
        }

        final scoreMap = _generateScoreMap(provider.allLogs, provider.totalActivities);
        debugPrint('Journey Screen: ScoreMap has ${scoreMap.length} entries');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perjalanan Saya'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekly Statistics
                  _buildWeeklyStats(provider),
                  const SizedBox(height: 24),
                  
                  // Progress Chart
                  Text(
                    'Grafik Progress 7 Hari',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProgressChart(scoreMap),
                  const SizedBox(height: 24),
                  
                  // Monthly Calendar
                  Text(
                    'Kalender Aktivitas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegend(),
                  const SizedBox(height: 12),
                  _buildMonthlyCalendar(scoreMap, provider),
                  const SizedBox(height: 16),
                  
                  // Selected Day Details
                  if (_selectedDay != null)
                    _buildDayDetails(provider),
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
            Icon(
              Icons.history_toggle_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Data Perjalanan',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai catat aktivitas harian Anda di halaman Home untuk melihat progress di sini.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStats(SelfCareProvider provider) {
    // Calculate weekly completion
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    int totalCompleted = 0;
    int totalPossible = 7 * provider.totalActivities;
    
    for (var day in last7Days) {
      final log = provider.allLogs.firstWhere(
        (log) => isSameDay(log.date, day),
        orElse: () => DailyLog(date: day, completedActivities: []),
      );
      totalCompleted += log.completedActivities.length;
    }
    
    final weeklyPercentage = totalPossible > 0 
        ? (totalCompleted / totalPossible * 100).round() 
        : 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Minggu Ini',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('d MMM').format(last7Days.first)} - ${DateFormat('d MMM').format(last7Days.last)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getColorForScore(weeklyPercentage),
                  child: Text(
                    '$weeklyPercentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle,
                    label: 'Selesai',
                    value: '$totalCompleted',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: '${provider.streak} hari',
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.calendar_today,
                    label: 'Total Hari',
                    value: '${provider.allLogs.length}',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem('Excellent', Colors.green.shade700, '80-100%'),
            _buildLegendItem('Good', Colors.lightGreen.shade400, '60-79%'),
            _buildLegendItem('Fair', Colors.orange.shade400, '40-59%'),
            _buildLegendItem('Low', Colors.red.shade300, '1-39%'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String range) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          range,
          style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildProgressChart(Map<DateTime, int> scores) {
    final List<FlSpot> spots = [];
    final List<String> dateLabels = [];
    
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final dayUtc = DateTime.utc(day.year, day.month, day.day);
      final score = scores[dayUtc] ?? 0;
      spots.add(FlSpot(6.0 - i, score.toDouble()));
      dateLabels.add('${day.day}/${day.month}');
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < dateLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                dateLabels[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
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
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Theme.of(context).primaryColor,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.blueGrey.shade800,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          return LineTooltipItem(
                            '${touchedSpot.y.toInt()}%',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendar(Map<DateTime, int> scores, SelfCareProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          availableCalendarFormats: const {
            CalendarFormat.month: 'Bulan',
            CalendarFormat.week: 'Minggu',
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            formatButtonTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ) ?? const TextStyle(),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
            weekendStyle: TextStyle(
              color: Colors.red.shade400,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final score = scores[DateTime.utc(day.year, day.month, day.day)] ?? 0;
              final color = _getColorForScore(score);
              final isToday = isSameDay(day, DateTime.now());
              
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isToday 
                      ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: score > 0 ? Colors.white : Colors.grey.shade700,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              final score = scores[DateTime.utc(day.year, day.month, day.day)] ?? 0;
              
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            todayBuilder: (context, day, focusedDay) {
              final score = scores[DateTime.utc(day.year, day.month, day.day)] ?? 0;
              final color = _getColorForScore(score);
              
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: color != Colors.grey.shade200 
                      ? color 
                      : Theme.of(context).primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: score > 0 ? Colors.white : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayDetails(SelfCareProvider provider) {
    if (_selectedDay == null) return const SizedBox.shrink();
    
    final log = provider.allLogs.firstWhere(
      (log) => isSameDay(log.date, _selectedDay!),
      orElse: () => DailyLog(date: _selectedDay!, completedActivities: []),
    );
    
    final activities = Activity.allActivities;
    final completionRate = activities.isEmpty 
        ? 0 
        : (log.completedActivities.length / activities.length * 100).round();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Aktivitas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay!),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _getColorForScore(completionRate),
                  child: Text(
                    '$completionRate%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (log.completedActivities.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tidak ada aktivitas yang diselesaikan',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ...activities.map((activity) {
                final isCompleted = log.completedActivities.contains(activity.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.cancel,
                        color: isCompleted ? Colors.green : Colors.grey.shade400,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Icon(activity.icon, color: activity.color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.name,
                          style: TextStyle(
                            fontSize: 15,
                            color: isCompleted 
                                ? Colors.black 
                                : Colors.grey.shade600,
                            fontWeight: isCompleted 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
