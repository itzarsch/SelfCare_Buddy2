class DailyLog {
  final DateTime date;
  final List<String> completedActivities;
  
  DailyLog({
    required this.date,
    required this.completedActivities,
  });
  
  // Get date without time (for comparison)
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);
  
  // Check if activity is completed
  bool isActivityCompleted(String activityId) {
    return completedActivities.contains(activityId);
  }
  
  // Get completion percentage
  double get completionPercentage {
    return completedActivities.isEmpty 
        ? 0 
        : (completedActivities.length / 5) * 100;
  }
  
  // Check if all activities completed
  bool get isAllCompleted => completedActivities.length == 5;
  
  // Copy with
  DailyLog copyWith({
    DateTime? date,
    List<String>? completedActivities,
  }) {
    return DailyLog(
      date: date ?? this.date,
      completedActivities: completedActivities ?? this.completedActivities,
    );
  }
}