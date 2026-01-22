import 'package:flutter/foundation.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/daily_log.dart';
import '../../domain/repositories/selfcare_repository.dart';

class SelfCareProvider extends ChangeNotifier {
  final SelfCareRepository _repository;
  
  DailyLog _todayLog;
  List<DailyLog> _allLogs = [];
  int _streak = 0;
  bool _isLoading = false;
  
  SelfCareProvider(this._repository) 
      : _todayLog = DailyLog(date: DateTime.now(), completedActivities: []) {
    _init();
  }
  
  // Getters
  DailyLog get todayLog => _todayLog;
  List<DailyLog> get allLogs => _allLogs;
  int get streak => _streak;
  bool get isLoading => _isLoading;
  
  List<Activity> get activities => Activity.allActivities;
  
  int get todayCompletedCount => _todayLog.completedActivities.length;
  int get totalActivities => activities.length;
  double get todayProgress => 
      (todayCompletedCount / totalActivities * 100).clamp(0, 100);
  
  bool isActivityCompleted(String activityId) {
    return _todayLog.isActivityCompleted(activityId);
  }
  
  // Initialize
  Future<void> _init() async {
    await loadTodayLog();
    await loadAllLogs();
    _calculateStreak();
  }
  
  // Load today's log
  Future<void> loadTodayLog() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _todayLog = _repository.getTodayLog();
    } catch (e) {
      debugPrint('Error loading today log: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Load all logs
  Future<void> loadAllLogs() async {
    try {
      _allLogs = _repository.getAllLogs();
    } catch (e) {
      debugPrint('Error loading all logs: $e');
    }
    notifyListeners();
  }
  
  // Toggle activity
  Future<bool> toggleActivity(String activityId) async {
    final success = await _repository.toggleActivity(
      DateTime.now(),
      activityId,
    );
    
    if (success) {
      await loadTodayLog();
      await loadAllLogs();
      _calculateStreak();
      notifyListeners();
    }
    
    return success;
  }
  
  // Calculate streak
  void _calculateStreak() {
    _streak = _repository.calculateStreak();
  }
  
  // Get logs for specific date range
  List<DailyLog> getLogsForRange(DateTime start, DateTime end) {
    return _repository.getLogsInRange(start, end);
  }
  
  // Get weekly stats
  Map<String, int> getWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return _repository.getCompletionStats(weekStart, weekEnd);
  }
  
  // Get monthly stats
  Map<String, int> getMonthlyStats() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    return _repository.getCompletionStats(monthStart, monthEnd);
  }
  
  // Refresh all data
  Future<void> refresh() async {
    await loadTodayLog();
    await loadAllLogs();
    _calculateStreak();
  }
  
  // Clear all data (for testing/reset)
  Future<bool> clearAllData() async {
    final success = await _repository.clearAllData();
    if (success) {
      await refresh();
    }
    return success;
  }
}