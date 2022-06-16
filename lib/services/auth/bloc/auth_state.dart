import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

// State of AuthState that indicates the application is uninitialzed.
class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

// State of AuthState that indicates the user is registering.
class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(this.exception);
}

// State of AuthState that indicates the user is logged in.
class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

// State of AuthState that indicates the user must verify their email.
class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

// State of AuthState that indicates the user is logged out (meaning
// they should be in the log in screen/not in the notes view).
// Since internals can be different, we need to include EquatableMixin
// to differentiate the different states of AuthStateLoggedOut.
// This state will also determine the loading screen for logging in/out.
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateLoggedOut({
    required this.exception,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}
