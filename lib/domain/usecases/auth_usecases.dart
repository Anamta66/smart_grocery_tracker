// lib/domain/usecases/auth_usecases.dart

import 'package:smart_grocery_tracker/data/models/user_model.dart';

import '../entities/user.dart';
import '../../data/repositories/auth_repository.dart';

/// UseCase:  SignIn
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserModel> call(String email, String password) async {
    // Validate input
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }

    // Call repository
    return await repository.signIn(email: email, password: password);
  }
}

/// UseCase: SignUp
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserModel> call({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    // Validate input
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Call repository
    return await repository.signUp(
        name: name, email: email, password: password, phone: phone);
  }
}

/// UseCase: Sign Out
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.signOut();
  }
}

/// UseCase: Get Current User
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserModel> call() async {
    final user = repository.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in');
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      phone: '', // optional, fetch from Firestore if needed
      role: UserRole.customer,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// UseCase: Reset Password
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call(String email) async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }

    return await repository.resetPassword(email);
  }
}
