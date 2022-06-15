import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

// State of AuthState that indicates the application is loading.
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

// State of AuthState that indicates the user is logged in.
class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

// State of AuthState that indicates the user has failed to log in.
class AuthStateLoginFailure extends AuthState {
  final Exception exception;
  const AuthStateLoginFailure(this.exception);
}

// State of AuthState that indicates the user must verify their email.
class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

// State of AuthState that indicates the user is logged out.
class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

// State of AuthState that indicates the user has failed to log out.
class AuthStateLogoutFailure extends AuthState {
  final Exception exception;
  const AuthStateLogoutFailure(this.exception);
}
