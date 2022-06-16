import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Wait just a moment...',
  });
}

// State of AuthState that indicates the application is uninitialzed.
class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

// State of AuthState that indicates the user is registering.
class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

// State of AuthState that indicates the user is logged in.
class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({
    required this.user,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

// State of AuthState that indicates the user must verify their email.
class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required bool isLoading})
      : super(isLoading: isLoading);
}

// State of AuthState that indicates the user is logged out (meaning
// they should be in the log in screen/not in the notes view).
// Since internals can be different, we need to include EquatableMixin
// to differentiate the different states of AuthStateLoggedOut.
// This state will also determine the loading screen for logging in/out.
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}
