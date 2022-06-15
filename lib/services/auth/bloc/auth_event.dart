import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

// Event of AuthEvent that the authentication service is initalizing.
class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

// Event of AuthEvent that the user is trying to log in.
class AuthEventLogIn extends AuthEvent {
  // LogIn event will take an email and password.
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

// Event of AuthEvent that the user is trying to log out.
class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
