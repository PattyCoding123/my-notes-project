import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

// Event of AuthEvent that indicates the authentication service is initalizing.
class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

// Event of AuthEvent that indicates the authentication service is sending
// a verification email.
class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

// Event of AuthEvent that indicates the user is trying to register.
class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

// Event of AuthEvent that indicates the user should register.
class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

// Event of AuthEvent that indicates the user is trying to log in.
class AuthEventLogIn extends AuthEvent {
  // LogIn event will take an email and password.
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

// Event of AuthEvent that indicates the user is trying to reset their password.
class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

// Event of AuthEvent that indicates the user is trying to log out.
class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
