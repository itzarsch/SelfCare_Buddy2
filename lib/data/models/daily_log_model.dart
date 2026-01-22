import 'dart:convert';
import '../../domain/entities/daily_log.dart';

class DailyLogModel extends DailyLog {
  DailyLogModel({
    required super.date,
    required super.completedActivities,
  });
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'completedActivities': completedActivities,
    };
  }
  
  // Create from JSON
  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      date: DateTime.parse(json['date']),
      completedActivities: List<String>.from(json['completedActivities']),
    );
  }
  
  // Convert to entity
  DailyLog toEntity() {
    return DailyLog(
      date: date,
      completedActivities: completedActivities,
    );
  }
  
  // Create from entity
  factory DailyLogModel.fromEntity(DailyLog entity) {
    return DailyLogModel(
      date: entity.date,
      completedActivities: entity.completedActivities,
    );
  }
  
  // Encode to string for SharedPreferences
  String encode() => json.encode(toJson());
  
  // Decode from string
  static DailyLogModel decode(String source) => 
      DailyLogModel.fromJson(json.decode(source));
}