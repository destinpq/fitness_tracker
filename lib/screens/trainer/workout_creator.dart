import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../models/workout.dart';

class WorkoutCreator extends StatefulWidget {
  const WorkoutCreator({super.key});

  @override
  State<WorkoutCreator> createState() => _WorkoutCreatorState();
}

class _WorkoutCreatorState extends State<WorkoutCreator> {
  final _formKey = GlobalKey<FormState>();
  final _workoutNameController = TextEditingController();
  final List<_ExerciseFormField> _exercises = [];

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(_ExerciseFormField(
        onDelete: () => _removeExercise(_exercises.length - 1),
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      // Create workout and save
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _workoutNameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  hintText: 'Enter workout name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workout name';
                  }
                  return null;
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) => _exercises[index],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExerciseFormField extends StatefulWidget {
  final VoidCallback onDelete;

  const _ExerciseFormField({
    required this.onDelete,
  });

  @override
  State<_ExerciseFormField> createState() => _ExerciseFormFieldState();
}

class _ExerciseFormFieldState extends State<_ExerciseFormField> {
  final _exerciseNameController = TextEditingController();
  final List<_SetField> _sets = [];

  @override
  void initState() {
    super.initState();
    _addSet(); // Add initial set
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }

  void _addSet() {
    setState(() {
      _sets.add(_SetField(
        onDelete: () => _removeSet(_sets.length - 1),
      ));
    });
  }

  void _removeSet(int index) {
    setState(() {
      _sets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _exerciseNameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      hintText: 'Enter exercise name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an exercise name';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_sets.length, (index) => _sets[index]),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
              onPressed: _addSet,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetField extends StatelessWidget {
  final VoidCallback onDelete;

  const _SetField({
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reps',
                hintText: 'Enter reps',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (int.tryParse(value) == null) {
                  return 'Enter a number';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'Enter weight',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a number';
                }
                return null;
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onDelete,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
