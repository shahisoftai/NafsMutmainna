import '../../../domain/entities/user.dart';
import '../../../../core/logger/logger.dart';

/// Abstract remote auth source. Auth is OPTIONAL in v1 (defer to v1.1).
/// v1 ships with a no-op so the rest of the app compiles and runs.
abstract class RemoteAuthDataSource {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, String? displayName);
  Future<void> signOut();
  Future<bool> isAuthenticated();
}

class NoopAuthDataSource implements RemoteAuthDataSource {
  @override
  Future<User> signIn(String email, String password) async =>
      throw UnsupportedError('Auth is disabled in v1 (deferred to v1.1).');

  @override
  Future<User> signUp(String email, String password, String? displayName) async =>
      throw UnsupportedError('Auth is disabled in v1 (deferred to v1.1).');

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> isAuthenticated() async {
    Logger.debug('NoopAuthDataSource.isAuthenticated returning false');
    return false;
  }
}
