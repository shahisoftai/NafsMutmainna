import 'package:nafsmutmainna/src/domain/entities/user.dart';

/// Authentication repository interface.
/// v1.0: auth is OPTIONAL — see IMPLEMENTATION_PLAN.md. Methods exist for
/// forward compatibility but are not exercised in the 5-screen loop.
abstract class AuthRepositoryInterface {
  /// Get currently authenticated user (cached). Returns null if not authed.
  Future<User?> getCurrentUser();

  /// Sign in with email and password.
  Future<User> signIn({required String email, required String password});

  /// Sign up with email and password.
  Future<User> signUp({required String email, required String password, String? displayName});

  /// Sign out.
  Future<void> signOut();

  /// Check if user is authenticated.
  Future<bool> isAuthenticated();
}