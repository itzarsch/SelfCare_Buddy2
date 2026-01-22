import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_log_model.dart';

class LocalDatasource {
  static const String _keyPrefix = 'daily_log_';
  static const String _keyAllDates = 'all_dates';
  
  final SharedPreferences _prefs;
  
  LocalDatasource(this._prefs);
  
  // Save daily log
  Future<bool> saveDailyLog(DailyLogModel log) async {
    try {
      final key = _getKeyForDate(log.date);
      final encoded = log.encode();
      
      print('LocalDatasource: Saving log for ${log.date} with key: $key');
      print('LocalDatasource: Activities: ${log.completedActivities}');
      
      // Save the log
      final saved = await _prefs.setString(key, encoded);
      
      print('LocalDatasource: Save result: $saved');
      
      // Update list of all dates
      if (saved) {
        await _addDateToList(log.date);
        print('LocalDatasource: Date added to list');
      }
      
      return saved;
    } catch (e) {
      print('LocalDatasource: Error saving log: $e');
      return false;
    }
  }
  
  // Get daily log by date
  DailyLogModel? getDailyLog(DateTime date) {
    try {
      final key = _getKeyForDate(date);
      final encoded = _prefs.getString(key);
      
      if (encoded == null) return null;
      
      return DailyLogModel.decode(encoded);
    } catch (e) {
      return null;
    }
  }
  
  // Get all daily logs
  List<DailyLogModel> getAllDailyLogs() {
    try {
      final dates = _getAllDates();
      print('LocalDatasource: getAllDailyLogs - Found ${dates.length} dates');
      
      final logs = <DailyLogModel>[];
      
      for (final dateStr in dates) {
        final date = DateTime.parse(dateStr);
        final log = getDailyLog(date);
        if (log != null) {
          print('LocalDatasource: Loaded log for $dateStr with ${log.completedActivities.length} activities');
          logs.add(log);
        } else {
          print('LocalDatasource: No log found for $dateStr');
        }
      }
      
      // Sort by date descending (newest first)
      logs.sort((a, b) => b.date.compareTo(a.date));
      
      print('LocalDatasource: Returning ${logs.length} logs');
      return logs;
    } catch (e) {
      print('LocalDatasource: Error in getAllDailyLogs: $e');
      return [];
    }
  }
  
  // Get logs for date range
  List<DailyLogModel> getLogsInRange(DateTime start, DateTime end) {
    final allLogs = getAllDailyLogs();
    return allLogs.where((log) {
      final logDate = log.dateOnly;
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      return (logDate.isAfter(startDate) || logDate.isAtSameMomentAs(startDate)) &&
             (logDate.isBefore(endDate) || logDate.isAtSameMomentAs(endDate));
    }).toList();
  }
  
  // Delete daily log
  Future<bool> deleteDailyLog(DateTime date) async {
    try {
      final key = _getKeyForDate(date);
      final removed = await _prefs.remove(key);
      
      if (removed) {
        await _removeDateFromList(date);
      }
      
      return removed;
    } catch (e) {
      return false;
    }
  }
  
  // Clear all data
  Future<bool> clearAll() async {
    try {
      final dates = _getAllDates();
      
      for (final dateStr in dates) {
        final date = DateTime.parse(dateStr);
        await deleteDailyLog(date);
      }
      
      await _prefs.remove(_keyAllDates);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Helper: Get key for specific date
  String _getKeyForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return '$_keyPrefix${dateOnly.toIso8601String()}';
  }
  
  // Helper: Get all stored dates
  List<String> _getAllDates() {
    final datesJson = _prefs.getString(_keyAllDates);
    if (datesJson == null) return [];
    
    try {
      return List<String>.from(json.decode(datesJson));
    } catch (e) {
      return [];
    }
  }
  
  // Helper: Add date to list
  Future<void> _addDateToList(DateTime date) async {
    final dates = _getAllDates();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final dateStr = dateOnly.toIso8601String();
    
    if (!dates.contains(dateStr)) {
      dates.add(dateStr);
      await _prefs.setString(_keyAllDates, json.encode(dates));
    }
  }
  
  // Helper: Remove date from list
  Future<void> _removeDateFromList(DateTime date) async {
    final dates = _getAllDates();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final dateStr = dateOnly.toIso8601String();
    
    dates.remove(dateStr);
    await _prefs.setString(_keyAllDates, json.encode(dates));
  }
}