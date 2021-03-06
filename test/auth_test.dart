import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Mock Authentication',
    () {
      final provider = MockAuthProvider();
      test(
        'Should not be initialized to begin with',
        () {
          expect(
            provider.isInitialized,
            false,
          );
        },
      );

      test(
        'Cannot log out if not initialized',
        () {
          expect(
            provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>()),
          );
        },
      );

      test(
        'Should be able to be initialized',
        () async {
          await provider.initialize();
          expect(
            provider.isInitialized,
            true,
          );
        },
      );

      test(
        'User should be null after initialization',
        () {
          expect(
            provider.currentUser,
            null,
          );
        },
      );

      test(
        'Should be able initialize in less than 2 seconds',
        () async {
          await provider.initialize();
          expect(
            provider.isInitialized,
            true,
          );
        },
        timeout: const Timeout(Duration(seconds: 2)),
      );

      test(
        'Create user should delegate to the log in function',
        () async {
          final badEmailUser = provider.createUser(
            email: 'foo@bar.com',
            password: 'anypassword',
          );
          expect(
            badEmailUser,
            throwsA(const TypeMatcher<UserNotFoundAuthException>()),
          );

          final badPasswordUser = provider.createUser(
            email: 'someone@bar.com',
            password: 'foobar',
          );
          expect(
            badPasswordUser,
            throwsA(const TypeMatcher<WrongPasswordAuthException>()),
          );

          final user = await provider.createUser(
            email: 'email',
            password: 'password',
          );
          expect(
            provider.currentUser,
            user,
          );
          expect(
            user.isEmailVerified,
            false,
          );
        },
      );

      test(
        'Logged in user should be able to get verified',
        () async {
          // Do not await sendEmailVerification as we have nothing to await for
          provider.sendEmailVerification();
          final user = provider.currentUser;
          expect(user, isNotNull);

          expect(
            user?.isEmailVerified,
            true,
          );
        },
      );

      test(
        'Should be able to log out and log in again',
        () async {
          await provider.logOut();
          await provider.logIn(
            email: 'email',
            password: 'password',
          );

          final user = provider.currentUser;
          expect(
            user,
            isNotNull,
          );
        },
      );

      test(
        'Should be able to catch errors when resetting password',
        () async {
          expect(provider.sendPasswordReset(toEmail: 'not-email'),
              throwsA(const TypeMatcher<InvalidEmailAuthException>()));

          expect(provider.sendPasswordReset(toEmail: 'cannot-find-user'),
              throwsA(const TypeMatcher<UserNotFoundAuthException>()));
        },
      );
    },
  );
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1)); // Mock 1-second wait

    // Mock logIn, returns Future<AuthUser>
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    // Add extra functionality to Mock logIn method to test them later
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(
      id: 'id',
      isEmailVerified: false,
      email: 'email',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      id: 'id',
      isEmailVerified: true,
      email: 'email',
    );
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    if (toEmail == 'not-email') {
      throw InvalidEmailAuthException();
    } else if (toEmail == 'cannot-find-user') {
      throw UserNotFoundAuthException();
    } else {
      await Future.delayed(
        const Duration(seconds: 2),
      );
    }
  }
}
