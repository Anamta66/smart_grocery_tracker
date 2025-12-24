// lib/data/repositories/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

/// Repository handling all authentication operations
/// Implements Clean Architecture data layer pattern
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up new user with email and password
  /// Creates user document in Firestore with profile data
  ///
  /// Throws:
  /// - [FirebaseAuthException] if signup fails
  /// - [Exception] for other errors
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to create user account');
      }

      // Create user profile in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
        notificationsEnabled: true,
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      // Update display name
      await user.updateDisplayName(name);

      return userModel;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already registered');
        case 'weak-password':
          throw Exception('Password is too weak');
        case 'invalid-email':
          throw Exception('Invalid email address');
        default:
          throw Exception('Signup failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred during signup: $e');
    }
  }

  /// Sign in existing user with email and password
  ///
  /// Returns [UserModel] with user data from Firestore
  ///
  /// Throws:
  /// - [FirebaseAuthException] if login fails
  /// - [Exception] for other errors
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Authenticate user
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Login failed');
      }

      // Fetch user data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        throw Exception('User profile not found');
      }

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email');
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred during login: $e');
    }
  }

  /// Sign out current user
  ///
  /// Throws [Exception] if signout fails
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get user profile data from Firestore
  ///
  /// Returns [UserModel] or null if not found
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile in Firestore
  ///
  /// Updates fields like name, phone, notifications preference
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Reset password via email
  ///
  /// Sends password reset link to user's email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email');
        case 'invalid-email':
          throw Exception('Invalid email address');
        default:
          throw Exception('Failed to send reset email: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred:  $e');
    }
  }

  /// Delete user account and all associated data
  ///
  /// WARNING: This is irreversible
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
