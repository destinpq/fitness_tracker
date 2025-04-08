import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/workout.dart';
import '../../models/exercise.dart';
import '../../services/auth_service.dart';
import 'analytics_view.dart';

class LiveWorkoutView extends StatefulWidget {
  const LiveWorkoutView({super.key});

  @override
  State<LiveWorkoutView> createState() => _LiveWorkoutViewState();
}

class _LiveWorkoutViewState extends State<LiveWorkoutView> {
  bool _isResting = false;
  int _currentRestSeconds = 0;
  Timer? _restTimer;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _WorkoutContent(),
    const AnalyticsView(),
  ];

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _currentRestSeconds = seconds;
      _isResting = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentRestSeconds > 0) {
          _currentRestSeconds--;
        } else {
          _isResting = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackMe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/auth/login');
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

class _WorkoutContent extends StatefulWidget {
  const _WorkoutContent();

  @override
  State<_WorkoutContent> createState() => _WorkoutContentState();
}

class _WorkoutContentState extends State<_WorkoutContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isResting) _buildRestTimer(),
        Expanded(
          child: _buildCurrentExercise(),
        ),
        _buildWorkoutProgress(),
      ],
    );
  }

  bool _isResting = false;
  int _currentRestSeconds = 0;
  Timer? _restTimer;

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _currentRestSeconds = seconds;
      _isResting = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentRestSeconds > 0) {
          _currentRestSeconds--;
        } else {
          _isResting = false;
          timer.cancel();
        }
      });
    });
  }

  Widget _buildRestTimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.blue.shade100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'REST TIME',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$_currentRestSeconds',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Next set starting soon...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExercise() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Barbell Squat',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MetricDisplay(
                    label: 'SET',
                    value: '2/3',
                  ),
                  SizedBox(width: 32),
                  _MetricDisplay(
                    label: 'REPS',
                    value: '12',
                  ),
                  SizedBox(width: 32),
                  _MetricDisplay(
                    label: 'WEIGHT',
                    value: '50kg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Follow your trainer\'s instructions',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workout Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '3/8 exercises',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 3 / 8,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                icon: Icons.timer,
                label: 'Duration',
                value: '45:30',
              ),
              _buildStat(
                icon: Icons.fitness_center,
                label: 'Volume',
                value: '2,450kg',
              ),
              _buildStat(
                icon: Icons.local_fire_department,
                label: 'Sets Done',
                value: '12/24',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _MetricDisplay extends StatelessWidget {
  final String label;
  final String value;

  const _MetricDisplay({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
