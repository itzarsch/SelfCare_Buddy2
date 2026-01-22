import '../../domain/entities/daily_log.dart';
import '../../domain/repositories/selfcare_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/daily_log_model.dart';

class SelfCareRepositoryImpl implements SelfCareRepository {
  final LocalDatasource _datasource;
  
  SelfCareRepositoryImpl(this._datasource);
  
  @override
  Future<bool> saveDailyLog(DailyLog log) async {
    final model = DailyLogModel.fromEntity(log);
    return await _datasource.saveDailyLog(model);
  }
  
  @override
  DailyLog? getDailyLog(DateTime date) {
    final model = _datasource.getDailyLog(date);
    return model?.toEntity();
  }
  
  @override
  DailyLog getTodayLog() {
    final today = DateTime.now();
    final log = getDailyLog(today);
    
    if (log != null) return log;
    
    // Return empty log for today
    return DailyLog(
      date: today,
      completedActivities: [],
    );
  }
  
  @override
  List<DailyLog> getAllLogs() {
    final models = _datasource.getAllDailyLogs();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  List<DailyLog> getLogsInRange(DateTime start, DateTime end) {
    final models = _datasource.getLogsInRange(start, end);
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<bool> toggleActivity(DateTime date, String activityId) async {
    final currentLog = getDailyLog(date);
    final activities = currentLog?.completedActivities ?? [];
    
    final updatedActivities = List<String>.from(activities);
    
    if (updatedActivities.contains(activityId)) {
      updatedActivities.remove(activityId);
    } else {
      updatedActivities.add(activityId);
    }
    
    final newLog = DailyLog(
      date: date,
      completedActivities: updatedActivities,
    );
    
    return await saveDailyLog(newLog);
  }
  
  @override
  int calculateStreak() {
    final allLogs = getAllLogs();
    if (allLogs.isEmpty) return 0;
    
    // Sort by date descending
    allLogs.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final log in allLogs) {
      // Only count days with at least 1 completed activity
      if (log.completedActivities.isEmpty) continue;
      
      final logDate = log.dateOnly;
      
      if (lastDate == null) {
        // First log with activities
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
        
        // Check if it's today or yesterday
        final diff = todayOnly.difference(logDate).inDays;
        if (diff <= 1) {
          streak = 1;
          lastDate = logDate;
        } else {
          break; // Streak broken
        }
      } else {
        // Check if consecutive day
        final diff = lastDate.difference(logDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = logDate;
        } else {
          break; // Streak broken
        }
      }
    }
    
    return streak;
  }
  
  @override
  Map<String, int> getCompletionStats(DateTime start, DateTime end) {
    final logs = getLogsInRange(start, end);
    final stats = <String, int>{};
    
    for (final log in logs) {
      for (final activityId in log.completedActivities) {
        stats[activityId] = (stats[activityId] ?? 0) + 1;
      }
    }
    
    return stats;
  }
  
  @override
  Future<bool> deleteLog(DateTime date) async {
    return await _datasource.deleteDailyLog(date);
  }
  
  @override
  Future<bool> clearAllData() async {
    return await _datasource.clearAll();
  }
}