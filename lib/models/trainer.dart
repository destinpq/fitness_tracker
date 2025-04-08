class Trainer {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? specialization;
  final String? bio;
  final List<String> certifications;
  final List<String> assignedUsers;
  final Map<String, dynamic> stats;

  Trainer({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.specialization,
    this.bio,
    List<String>? certifications,
    List<String>? assignedUsers,
    Map<String, dynamic>? stats,
  })  : certifications = certifications ?? [],
        assignedUsers = assignedUsers ?? [],
        stats = stats ?? {
          'totalSessions': 0,
          'activeClients': 0,
          'totalWorkoutTime': 0,
          'averageSessionRating': 0.0,
          'completionRate': 100.0,
        };

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
    'specialization': specialization,
    'bio': bio,
    'certifications': certifications,
    'assignedUsers': assignedUsers,
    'stats': stats,
  };

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    photoUrl: json['photoUrl'],
    specialization: json['specialization'],
    bio: json['bio'],
    certifications: List<String>.from(json['certifications'] ?? []),
    assignedUsers: List<String>.from(json['assignedUsers'] ?? []),
    stats: Map<String, dynamic>.from(json['stats'] ?? {}),
  );

  Trainer copyWith({
    String? name,
    String? photoUrl,
    String? specialization,
    String? bio,
    List<String>? certifications,
    List<String>? assignedUsers,
    Map<String, dynamic>? stats,
  }) {
    return Trainer(
      id: id,
      email: email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      specialization: specialization ?? this.specialization,
      bio: bio ?? this.bio,
      certifications: certifications ?? this.certifications,
      assignedUsers: assignedUsers ?? this.assignedUsers,
      stats: stats ?? this.stats,
    );
  }

  void updateStats(Map<String, dynamic> sessionData) {
    stats['totalSessions'] = (stats['totalSessions'] ?? 0) + 1;
    stats['activeClients'] = assignedUsers.length;
    stats['totalWorkoutTime'] = (stats['totalWorkoutTime'] ?? 0) + 
        (sessionData['duration'] ?? 0);
    
    if (sessionData['rating'] != null) {
      final currentRating = stats['averageSessionRating'] ?? 0.0;
      final totalSessions = stats['totalSessions'];
      stats['averageSessionRating'] = 
          ((currentRating * (totalSessions - 1)) + sessionData['rating']) / totalSessions;
    }
    
    if (sessionData['completed'] != null) {
      final totalSessions = stats['totalSessions'];
      final completedSessions = (stats['completedSessions'] ?? 0) + 
          (sessionData['completed'] ? 1 : 0);
      stats['completionRate'] = (completedSessions / totalSessions) * 100;
    }
  }

  bool canAddUser() {
    // Limit of 20 active clients per trainer
    return assignedUsers.length < 20;
  }
}
