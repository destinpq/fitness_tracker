import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_models;
import '../models/trainer.dart';

enum UserRole {
  trainer,
  trainee,
}

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<UserRole?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final trainerDoc = await _firestore.collection('trainers').doc(user.uid).get();
    if (trainerDoc.exists) return UserRole.trainer;

    final traineeDoc = await _firestore.collection('users').doc(user.uid).get();
    if (traineeDoc.exists) return UserRole.trainee;

    return null;
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Authentication failed');
      }

      final role = await getCurrentUserRole();
      if (role == null) {
        throw Exception('User role not found');
      }

      return {
        'success': true,
        'role': role,
        'uid': userCredential.user!.uid,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> registerTrainer({
    required String email,
    required String password,
    required String name,
    String? specialization,
    String? bio,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Registration failed');
      }

      final trainer = Trainer(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        specialization: specialization,
        bio: bio,
      );

      await _firestore
          .collection('trainers')
          .doc(userCredential.user!.uid)
          .set(trainer.toJson());

      return {
        'success': true,
        'role': UserRole.trainer,
        'uid': userCredential.user!.uid,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Registration failed');
      }

      final user = app_models.User(
        id: userCredential.user!.uid,
        email: email,
        name: name,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toJson());

      return {
        'success': true,
        'role': UserRole.trainee,
        'uid': userCredential.user!.uid,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
