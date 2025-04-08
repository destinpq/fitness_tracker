class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final Map<String, dynamic> preferences;
  final List<String> assignedTrainers;
  final Map<String, dynamic> stats;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    Map<String, dynamic>? preferences,
    List<String>? assignedTrainers,
    Map<String, dynamic>? stats,
  })  : preferences = preferences ?? {},
        assignedTrainers = assignedTrainers ?? [],
        stats = stats ?? {
          'totalWorkouts': 0,
          'totalVolume': 0.0,
          'averageWorkoutDuration': 0,
          'streakDays': 0,
          'lastWorkout': null,
        };

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
    'preferences': preferences,
    'assignedTrainers': assignedTrainers,
    'stats': stats,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    photoUrl: json['photoUrl'],
    preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    assignedTrainers: List<String>.from(json['assignedTrainers'] ?? []),
    stats: Map<String, dynamic>.from(json['stats'] ?? {}),
  );

  User copyWith({
    String? name,
    String? photoUrl,
    Map<String, dynamic>? preferences,
    List<String>? assignedTrainers,
    Map<String, dynamic>? stats,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
      assignedTrainers: assignedTrainers ?? this.assignedTrainers,
      stats: stats ?? this.stats,
    );
  }

  void updateStats(Map<String, dynamic> workoutAnalytics) {
    stats['totalWorkouts'] = (stats['totalWorkouts'] ?? 0) + 1;
    stats['totalVolume'] = (stats['totalVolume'] ?? 0.0) + workoutAnalytics['totalVolume'];
    
    final lastWorkout = stats['lastWorkout'] != null 
        ? DateTime.parse(stats['lastWorkout'])
        : null;
    final now = DateTime.now();
    
    if (lastWorkout != null) {
      final difference = now.difference(lastWorkout).inDays;
      if (difference == 1) {
        stats['streakDays'] = (stats['streakDays'] ?? 0) + 1;
      } else if (difference > 1) {
        stats['streakDays'] = 1;
      }
    } else {
      stats['streakDays'] = 1;
    }
    
    stats['lastWorkout'] = now.toIso8601String();
    
    // Update average workout duration
    final totalWorkouts = stats['totalWorkouts'];
    final currentAvg = stats['averageWorkoutDuration'] ?? 0;
    final newDuration = workoutAnalytics['duration'];
    stats['averageWorkoutDuration'] = 
        ((currentAvg * (totalWorkouts - 1)) + newDuration) / totalWorkouts;
  }
}
