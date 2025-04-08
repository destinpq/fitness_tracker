import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView>
    with SingleTickerProviderStateMixin {
  final _analyticsService = AnalyticsService();
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;
  late TabController _tabController;
  String? _selectedExercise;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = AuthService().getCurrentUserRole();
      if (userId == null) return;

      final analytics = await _analyticsService.getUserAnalytics(userId.toString());
      
      if (mounted) {
        setState(() {
          _analytics = analytics;
          if (_selectedExercise == null &&
              (_analytics?['exerciseProgress'] as Map?)?.isNotEmpty == true) {
            _selectedExercise =
                (_analytics!['exerciseProgress'] as Map).keys.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_analytics == null) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Progress'),
            Tab(text: 'Records'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildProgressTab(),
              _buildRecordsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildWeeklyProgress(),
            const SizedBox(height: 24),
            _buildMonthlyProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _StatCard(
          title: 'Total Workouts',
          value: _analytics!['totalWorkouts'].toString(),
          icon: Icons.fitness_center,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'This Month',
          value: _analytics!['monthlyWorkouts'].toString(),
          icon: Icons.calendar_today,
          color: Colors.green,
        ),
        _StatCard(
          title: 'This Week',
          value: _analytics!['weeklyWorkouts'].toString(),
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Total Volume',
          value: '${(_analytics!['totalVolume'] / 1000).toStringAsFixed(1)}k kg',
          icon: Icons.bar_chart,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    final weeklyProgress = _analytics!['weeklyProgress'] as List;
    final volumeData = weeklyProgress
        .map((week) => FlSpot(
              weeklyProgress.indexOf(week).toDouble(),
              week['volume'] / 1000,
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= weeklyProgress.length) {
                            return const Text('');
                          }
                          final date = weeklyProgress[value.toInt()]['week'] as DateTime;
                          return Text('Week ${date.day}');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: volumeData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyProgress() {
    final monthlyProgress = _analytics!['monthlyProgress'] as List;
    final data = monthlyProgress
        .map((month) => FlSpot(
              monthlyProgress.indexOf(month).toDouble(),
              month['volume'] / 1000,
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Volume',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= monthlyProgress.length) {
                            return const Text('');
                          }
                          final date = monthlyProgress[value.toInt()]['month'] as DateTime;
                          return Text(DateFormat('MMM').format(date));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data
                      .map(
                        (spot) => BarChartGroupData(
                          x: spot.x.toInt(),
                          barRods: [
                            BarChartRodData(
                              toY: spot.y,
                              color: Colors.blue,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    if (_selectedExercise == null) {
      return const Center(child: Text('No exercises found'));
    }

    final exerciseProgress =
        _analytics!['exerciseProgress'] as Map<String, List<Map<String, dynamic>>>;
    final exercises = exerciseProgress.keys.toList();
    final selectedExerciseData = exerciseProgress[_selectedExercise]!;

    final volumeData = selectedExerciseData
        .map((data) => FlSpot(
              selectedExerciseData.indexOf(data).toDouble(),
              data['volume'].toDouble(),
            ))
        .toList();

    final weightData = selectedExerciseData
        .map((data) => FlSpot(
              selectedExerciseData.indexOf(data).toDouble(),
              data['maxWeight'].toDouble(),
            ))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedExercise,
            decoration: const InputDecoration(
              labelText: 'Select Exercise',
              border: OutlineInputBorder(),
            ),
            items: exercises
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedExercise = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedExercise!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value < 0 ||
                                    value >= selectedExerciseData.length) {
                                  return const Text('');
                                }
                                final date = selectedExerciseData[value.toInt()]
                                    ['date'] as DateTime;
                                return Text(DateFormat('MM/dd').format(date));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: volumeData,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: weightData,
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ChartLegend(
                        color: Colors.blue,
                        label: 'Volume',
                      ),
                      const SizedBox(width: 24),
                      _ChartLegend(
                        color: Colors.red,
                        label: 'Max Weight',
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

  Widget _buildRecordsTab() {
    final personalBests = _analytics!['personalBests'] as Map<String, dynamic>;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: personalBests.length,
      itemBuilder: (context, index) {
        final exercise = personalBests.keys.elementAt(index);
        final weight = personalBests[exercise];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.emoji_events),
            ),
            title: Text(exercise),
            subtitle: Text('Personal Best'),
            trailing: Text(
              '${weight.toStringAsFixed(1)} kg',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
