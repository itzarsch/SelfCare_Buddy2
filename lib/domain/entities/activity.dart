import 'package:flutter/material.dart';

enum ActivityType {
  water,
  food,
  sleep,
  exercise,
  meTime,
}

class Activity {
  final String id;
  final ActivityType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  
  Activity({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
  
  // Predefined activities
  static Activity get water => Activity(
    id: 'water',
    type: ActivityType.water,
    name: 'Minum Air',
    description: '8 gelas sehari',
    icon: Icons.water_drop_outlined,
    color: const Color(0xFF7EC8E3),
  );
  
  static Activity get food => Activity(
    id: 'food',
    type: ActivityType.food,
    name: 'Makan Teratur',
    description: '3x sehari',
    icon: Icons.restaurant_outlined,
    color: const Color(0xFF95D5B2),
  );
  
  static Activity get sleep => Activity(
    id: 'sleep',
    type: ActivityType.sleep,
    name: 'Istirahat Cukup',
    description: '7-8 jam',
    icon: Icons.bedtime_outlined,
    color: const Color(0xFFB4A7D6),
  );
  
  static Activity get exercise => Activity(
    id: 'exercise',
    type: ActivityType.exercise,
    name: 'Aktivitas Fisik',
    description: '15-30 menit',
    icon: Icons.directions_run_outlined,
    color: const Color(0xFFFFB88C),
  );
  
  static Activity get meTime => Activity(
    id: 'meTime',
    type: ActivityType.meTime,
    name: 'Me Time',
    description: 'Waktu untuk diri sendiri',
    icon: Icons.self_improvement_outlined,
    color: const Color(0xFFFFACC7),
  );
  
  static List<Activity> get allActivities => [
    water,
    food,
    sleep,
    exercise,
    meTime,
  ];
}