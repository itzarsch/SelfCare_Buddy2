import '../../domain/entities/daily_log.dart';

abstract class SelfCareRepository {
  // Save or update daily log
  Future<bool> saveDailyLog(DailyLog log);
  
  // Get daily log for specific date
  DailyLog? getDailyLog(DateTime date);
  
  // Get today's log
  DailyLog getTodayLog();
  
  // Get all daily logs
  List<DailyLog> getAllLogs();
  
  // Get logs for date range
  List<DailyLog> getLogsInRange(DateTime start, DateTime end);
  
  // Toggle activity completion
  Future<bool> toggleActivity(DateTime date, String activityId);
  
  // Calculate streak (consecutive days with at least 1 activity)
  int calculateStreak();
  
  // Get completion stats for a period
  Map<String, int> getCompletionStats(DateTime start, DateTime end);
  
  // Delete specific log
  Future<bool> deleteLog(DateTime date);
  
  // Clear all data
  Future<bool> clearAllData();
}