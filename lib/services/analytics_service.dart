import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getTrainerAnalytics(String trainerId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final workoutsQuery = await _firestore
        .collection('workouts')
        .where('trainerId', isEqualTo: trainerId)
        .get();

    final workouts = workoutsQuery.docs
        .map((doc) => Workout.fromJson(doc.data()))
        .toList();

    final monthlyWorkouts = workouts
        .where((w) => w.createdAt.isAfter(startOfMonth))
        .toList();
    
    final weeklyWorkouts = workouts
        .where((w) => w.createdAt.isAfter(startOfWeek))
        .toList();

    return {
      'totalWorkouts': workouts.length,
      'monthlyWorkouts': monthlyWorkouts.length,
      'weeklyWorkouts': weeklyWorkouts.length,
      'averageSessionDuration': _calculateAverageSessionDuration(workouts),
      'totalVolume': _calculateTotalVolume(workouts),
      'completionRate': _calculateCompletionRate(workouts),
      'weeklyStats': _calculateWeeklyStats(workouts),
      'monthlyStats': _calculateMonthlyStats(workouts),
      'popularExercises': _getPopularExercises(workouts),
    };
  }

  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    try {
      final workoutsRef = _firestore.collection('workouts')
          .where('userId', isEqualTo: userId);
      
      final workouts = await workoutsRef.get();
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      int totalWorkouts = workouts.docs.length;
      int monthlyWorkouts = workouts.docs
          .where((doc) => doc['date'].toDate().isAfter(startOfMonth))
          .length;
      int weeklyWorkouts = workouts.docs
          .where((doc) => doc['date'].toDate().isAfter(startOfWeek))
          .length;

      double totalVolume = 0;
      Map<String, List<Map<String, dynamic>>> exerciseProgress = {};
      Map<String, double> personalBests = {};

      for (var workout in workouts.docs) {
        final data = workout.data();
        final exercises = data['exercises'] as List<dynamic>;
        final date = (data['date'] as Timestamp).toDate();

        for (var exercise in exercises) {
          final name = exercise['name'] as String;
          final sets = exercise['sets'] as List<dynamic>;
          
          double workoutVolume = 0;
          double maxWeight = 0;

          for (var set in sets) {
            final reps = set['reps'] as int;
            final weight = set['weight'] as double;
            workoutVolume += reps * weight;
            maxWeight = maxWeight < weight ? weight : maxWeight;
          }

          totalVolume += workoutVolume;

          // Update personal bests
          if (!personalBests.containsKey(name) || personalBests[name]! < maxWeight) {
            personalBests[name] = maxWeight;
          }

          // Update exercise progress
          if (!exerciseProgress.containsKey(name)) {
            exerciseProgress[name] = [];
          }
          exerciseProgress[name]!.add({
            'date': date,
            'volume': workoutVolume,
            'maxWeight': maxWeight,
          });
        }
      }

      // Sort exercise progress by date
      exerciseProgress.forEach((_, list) {
        list.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      });

      // Calculate weekly progress
      final weeklyProgress = _calculateWeeklyProgress(workouts.docs);
      
      // Calculate monthly progress
      final monthlyProgress = _calculateMonthlyProgress(workouts.docs);

      return {
        'totalWorkouts': totalWorkouts,
        'monthlyWorkouts': monthlyWorkouts,
        'weeklyWorkouts': weeklyWorkouts,
        'totalVolume': totalVolume,
        'exerciseProgress': exerciseProgress,
        'personalBests': personalBests,
        'weeklyProgress': weeklyProgress,
        'monthlyProgress': monthlyProgress,
      };
    } catch (e) {
      print('Error getting user analytics: $e');
      rethrow;
    }
  }

  Duration _calculateAverageSessionDuration(List<Workout> workouts) {
    if (workouts.isEmpty) return Duration.zero;

    final totalDuration = workouts
        .where((w) => w.duration != null)
        .fold<Duration>(
          Duration.zero,
          (sum, workout) => sum + (workout.duration ?? Duration.zero),
        );

    return Duration(
      seconds: totalDuration.inSeconds ~/ workouts.length,
    );
  }

  double _calculateTotalVolume(List<Workout> workouts) {
    return workouts.fold<double>(
      0,
      (sum, workout) => sum + workout.totalVolume,
    );
  }

  double _calculateCompletionRate(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;

    final completedWorkouts = workouts
        .where((w) => w.status == WorkoutStatus.completed)
        .length;

    return (completedWorkouts / workouts.length) * 100;
  }

  List<Map<String, dynamic>> _calculateWeeklyStats(List<Workout> workouts) {
    final now = DateTime.now();
    final stats = <Map<String, dynamic>>[];

    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayWorkouts = workouts
          .where((w) =>
              w.createdAt.year == date.year &&
              w.createdAt.month == date.month &&
              w.createdAt.day == date.day)
          .toList();

      stats.add({
        'date': date,
        'workouts': dayWorkouts.length,
        'volume': _calculateTotalVolume(dayWorkouts),
      });
    }

    return stats;
  }

  List<Map<String, dynamic>> _calculateMonthlyStats(List<Workout> workouts) {
    final now = DateTime.now();
    final stats = <Map<String, dynamic>>[];

    for (var i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthWorkouts = workouts
          .where((w) =>
              w.createdAt.year == date.year &&
              w.createdAt.month == date.month)
          .toList();

      stats.add({
        'date': date,
        'workouts': monthWorkouts.length,
        'volume': _calculateTotalVolume(monthWorkouts),
      });
    }

    return stats;
  }

  List<Map<String, dynamic>> _getPopularExercises(List<Workout> workouts) {
    final exerciseCounts = <String, int>{};
    
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        exerciseCounts[exercise.name] = 
            (exerciseCounts[exercise.name] ?? 0) + 1;
      }
    }

    final sortedExercises = exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedExercises
        .take(10)
        .map((e) => {
              'name': e.key,
              'count': e.value,
            })
        .toList();
  }

  List<Map<String, dynamic>> _calculateWeeklyProgress(List<QueryDocumentSnapshot> workouts) {
    final Map<DateTime, double> weeklyVolumes = {};
    
    for (var workout in workouts) {
      final data = workout.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      
      double volume = 0;
      for (var exercise in data['exercises'] as List<dynamic>) {
        for (var set in exercise['sets'] as List<dynamic>) {
          volume += (set['reps'] as int) * (set['weight'] as double);
        }
      }

      weeklyVolumes.update(
        startOfWeek,
        (value) => value + volume,
        ifAbsent: () => volume,
      );
    }

    final sortedWeeks = weeklyVolumes.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return sortedWeeks.map((week) => {
      'week': week,
      'volume': weeklyVolumes[week],
    }).toList();
  }

  List<Map<String, dynamic>> _calculateMonthlyProgress(List<QueryDocumentSnapshot> workouts) {
    final Map<DateTime, double> monthlyVolumes = {};
    
    for (var workout in workouts) {
      final data = workout.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final startOfMonth = DateTime(date.year, date.month, 1);
      
      double volume = 0;
      for (var exercise in data['exercises'] as List<dynamic>) {
        for (var set in exercise['sets'] as List<dynamic>) {
          volume += (set['reps'] as int) * (set['weight'] as double);
        }
      }

      monthlyVolumes.update(
        startOfMonth,
        (value) => value + volume,
        ifAbsent: () => volume,
      );
    }

    final sortedMonths = monthlyVolumes.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return sortedMonths.map((month) => {
      'month': month,
      'volume': monthlyVolumes[month],
    }).toList();
  }
}
