import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/trainer/trainer_dashboard.dart';
import 'screens/trainer/analytics_dashboard.dart';
import 'screens/user/live_workout_view.dart';
import 'screens/user/analytics_view.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserRole?>(
      create: (_) => AuthService().authStateChanges.asyncMap((user) async {
        if (user == null) return null;
        return await AuthService().getCurrentUserRole();
      }),
      initialData: null,
      child: MaterialApp(
        title: 'TrackMe',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/auth/login': (context) => const LoginScreen(),
          '/auth/register': (context) => const RegisterScreen(),
          '/trainer/dashboard': (context) => const TrainerDashboard(),
          '/trainer/analytics': (context) => const AnalyticsDashboard(),
          '/user/live-workout': (context) => const LiveWorkoutView(),
          '/user/analytics': (context) => const AnalyticsView(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserRole?>(context);

    if (userRole == null) {
      return const LoginScreen();
    }

    switch (userRole) {
      case UserRole.trainer:
        return const TrainerDashboard();
      case UserRole.trainee:
        return const LiveWorkoutView();
      default:
        return const LoginScreen();
    }
  }
}
