import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trainer.dart';
import '../../models/workout.dart';
import '../../models/user.dart';
import 'live_session.dart';
import 'workout_creator.dart';
import '../../services/auth_service.dart';
import 'analytics_dashboard.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardContent(),
    const AnalyticsDashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
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
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  void _showWorkoutCreator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkoutCreator(),
      ),
    );
  }

  void _showClientInvite(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _InviteClientDialog(),
    );
  }

  void _startLiveSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveSession(),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Trainer Dashboard Content'),
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _StatCard(
          title: 'Active Clients',
          value: '12',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Today\'s Sessions',
          value: '5',
          icon: Icons.calendar_today,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Completion Rate',
          value: '95%',
          icon: Icons.check_circle,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Avg. Session Rating',
          value: '4.8',
          icon: Icons.star,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientsPanel extends StatelessWidget {
  const _ClientsPanel();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // Replace with actual client count
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text('Client ${index + 1}'),
          subtitle: Text('Last session: ${DateTime.now().toString().split(' ')[0]}'),
          trailing: IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: () {
              // Start workout with this client
            },
          ),
        );
      },
    );
  }
}

class _WorkoutsPanel extends StatelessWidget {
  const _WorkoutsPanel();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // Replace with actual workout count
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Workout ${index + 1}'),
            subtitle: const Text('Full Body Strength'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit workout
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Delete workout
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnalyticsPanel extends StatelessWidget {
  const _AnalyticsPanel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Analytics Coming Soon'),
    );
  }
}

class _InviteClientDialog extends StatelessWidget {
  const _InviteClientDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite New Client'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter client\'s email',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Personal Note',
              hintText: 'Add a personal message',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Send invitation
            Navigator.pop(context);
          },
          child: const Text('Send Invite'),
        ),
      ],
    );
  }
}
