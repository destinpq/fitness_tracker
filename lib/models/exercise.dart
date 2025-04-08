import 'package:uuid/uuid.dart';

class Set {
  final String id;
  final int targetReps;
  final double weight;
  bool isCompleted;
  DateTime? startTime;
  DateTime? endTime;
  int? actualReps;
  Duration? restPeriod;

  Set({
    String? id,
    required this.targetReps,
    required this.weight,
    this.isCompleted = false,
    this.startTime,
    this.endTime,
    this.actualReps,
    this.restPeriod,
  }) : id = id ?? const Uuid().v4();

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'targetReps': targetReps,
    'weight': weight,
    'isCompleted': isCompleted,
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'actualReps': actualReps,
    'restPeriod': restPeriod?.inSeconds,
  };

  factory Set.fromJson(Map<String, dynamic> json) => Set(
    id: json['id'],
    targetReps: json['targetReps'],
    weight: json['weight'].toDouble(),
    isCompleted: json['isCompleted'],
    startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    actualReps: json['actualReps'],
    restPeriod: json['restPeriod'] != null ? Duration(seconds: json['restPeriod']) : null,
  );
}

class Exercise {
  final String id;
  final String name;
  final String? description;
  final String? muscleGroup;
  final String? equipment;
  final List<Set> sets;
  final String? notes;
  final String? videoUrl;

  Exercise({
    String? id,
    required this.name,
    this.description,
    this.muscleGroup,
    this.equipment,
    List<Set>? sets,
    this.notes,
    this.videoUrl,
  }) : id = id ?? const Uuid().v4(),
       sets = sets ?? [];

  double get totalVolume {
    return sets.where((set) => set.isCompleted).fold(0, 
      (sum, set) => sum + (set.actualReps ?? set.targetReps) * set.weight);
  }

  Duration get totalRestTime {
    return sets.where((set) => set.restPeriod != null).fold(
      Duration.zero,
      (sum, set) => sum + (set.restPeriod ?? Duration.zero));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'muscleGroup': muscleGroup,
    'equipment': equipment,
    'sets': sets.map((set) => set.toJson()).toList(),
    'notes': notes,
    'videoUrl': videoUrl,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    muscleGroup: json['muscleGroup'],
    equipment: json['equipment'],
    sets: (json['sets'] as List).map((set) => Set.fromJson(set)).toList(),
    notes: json['notes'],
    videoUrl: json['videoUrl'],
  );
}
