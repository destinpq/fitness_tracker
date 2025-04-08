import 'package:uuid/uuid.dart';
import 'exercise.dart';

enum WorkoutStatus {
  planned,
  inProgress,
  completed,
  cancelled
}

class Workout {
  final String id;
  final String trainerId;
  final String userId;
  final String name;
  final DateTime createdAt;
  DateTime? startTime;
  DateTime? endTime;
  final List<Exercise> exercises;
  WorkoutStatus status;
  String? notes;

  Workout({
    String? id,
    required this.trainerId,
    required this.userId,
    required this.name,
    DateTime? createdAt,
    this.startTime,
    this.endTime,
    List<Exercise>? exercises,
    this.status = WorkoutStatus.planned,
    this.notes,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       exercises = exercises ?? [];

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) => sum + exercise.totalVolume);
  }

  Duration get totalRestTime {
    return exercises.fold(
      Duration.zero,
      (sum, exercise) => sum + exercise.totalRestTime);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trainerId': trainerId,
    'userId': userId,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    'status': status.toString(),
    'notes': notes,
  };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'],
    trainerId: json['trainerId'],
    userId: json['userId'],
    name: json['name'],
    createdAt: DateTime.parse(json['createdAt']),
    startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    exercises: (json['exercises'] as List)
        .map((exercise) => Exercise.fromJson(exercise))
        .toList(),
    status: WorkoutStatus.values.firstWhere(
      (e) => e.toString() == json['status'],
      orElse: () => WorkoutStatus.planned),
    notes: json['notes'],
  );

  Map<String, dynamic> getAnalytics() {
    return {
      'totalVolume': totalVolume,
      'totalExercises': exercises.length,
      'completedExercises': exercises
          .where((e) => e.sets.every((s) => s.isCompleted))
          .length,
      'totalSets': exercises.fold(0, (sum, e) => sum + e.sets.length),
      'completedSets': exercises.fold(
        0,
        (sum, e) => sum + e.sets.where((s) => s.isCompleted).length),
      'duration': duration?.inMinutes ?? 0,
      'totalRestTime': totalRestTime.inMinutes,
    };
  }
}
