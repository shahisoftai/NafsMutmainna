import '../../domain/entities/user.dart';
import '../../../core/logger/logger.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_auth_datasource.dart';
import '../datasources/remote/remote_auth_datasource.dart';

/// Auth repository following Dependency Inversion Principle.
/// v1.0: auth is OPTIONAL — defaults to NoopAuthDataSource.
/// v1.1: will swap in Supabase / Google.
class AuthRepositoryImpl implements AuthRepositoryInterface {
  final RemoteAuthDataSource _remote;
  final ILocalAuthDataSource _local;

  AuthRepositoryImpl({required RemoteAuthDataSource remote, required ILocalAuthDataSource local})
      : _remote = remote,
        _local = local;

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await _local.getCachedUser();
    } catch (e) {
      Logger.error('AuthRepositoryImpl: getCurrentUser failed', error: e);
      return null;
    }
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    return _remote.signIn(email, password);
  }

  @override
  Future<User> signUp({required String email, required String password, String? displayName}) async {
    final user = await _remote.signUp(email, password, displayName);
    await _local.cacheUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    try {
      await _remote.signOut();
    } finally {
      await _local.clearAuthData();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await _remote.isAuthenticated();
    } catch (e) {
      Logger.error('AuthRepositoryImpl: isAuthenticated failed', error: e);
      return false;
    }
  }
}
