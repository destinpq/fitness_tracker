import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/workout.dart';
import '../../models/exercise.dart';

class LiveSession extends StatefulWidget {
  const LiveSession({super.key});

  @override
  State<LiveSession> createState() => _LiveSessionState();
}

class _LiveSessionState extends State<LiveSession> {
  Timer? _restTimer;
  int _currentRestSeconds = 0;
  bool _isResting = false;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;

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
        title: const Text('Live Session'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.stop),
            label: const Text('End Session'),
            onPressed: () => _showEndSessionDialog(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildWorkoutPanel(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            flex: 1,
            child: _buildControlPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPanel() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Replace with actual exercise count
            itemBuilder: (context, index) {
              final isCurrentExercise = index == _currentExerciseIndex;
              return Card(
                margin: const EdgeInsets.all(8),
                color: isCurrentExercise ? Colors.blue.shade50 : null,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Exercise ${index + 1}',
                        style: TextStyle(
                          fontWeight:
                              isCurrentExercise ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: const Text('3 sets × 12 reps'),
                      trailing: isCurrentExercise
                          ? const Icon(Icons.fitness_center, color: Colors.blue)
                          : null,
                    ),
                    if (isCurrentExercise) ...[
                      const Divider(),
                      _buildSetsList(),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        if (_isResting) _buildRestTimer(),
      ],
    );
  }

  Widget _buildSetsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          3, // Replace with actual sets count
          (index) => _buildSetTile(index),
        ),
      ),
    );
  }

  Widget _buildSetTile(int setIndex) {
    final isCurrentSet = setIndex == _currentSetIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Set ${setIndex + 1}',
              style: TextStyle(
                fontWeight: isCurrentSet ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const Text('12 reps @ 50kg'),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: isCurrentSet ? () => _completeSet(setIndex) : null,
            color: isCurrentSet ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, size: 32),
          const SizedBox(width: 16),
          Text(
            'Rest: ${_currentRestSeconds}s',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _isResting = false;
                _restTimer?.cancel();
              });
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Current Exercise',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Barbell Squat',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MetricDisplay(
                        label: 'Weight',
                        value: '50kg',
                      ),
                      SizedBox(width: 16),
                      _MetricDisplay(
                        label: 'Reps',
                        value: '12',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isResting ? null : () => _startRestTimer(60),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
            ),
            child: const Text(
              'Start Rest Timer',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              // Skip to next exercise
            },
            child: const Text('Skip Exercise'),
          ),
          const Spacer(),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Session Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricDisplay(
                        label: 'Duration',
                        value: '45:30',
                      ),
                      _MetricDisplay(
                        label: 'Volume',
                        value: '2,450kg',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeSet(int setIndex) {
    // Mark set as completed and start rest timer
    setState(() {
      _currentSetIndex++;
      if (_currentSetIndex >= 3) { // Replace with actual sets count
        _currentSetIndex = 0;
        _currentExerciseIndex++;
      }
    });
    _startRestTimer(60);
  }

  Future<void> _showEndSessionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save session data and return to dashboard
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
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
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
