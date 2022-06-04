import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified);

  // Factory constructor that initializes a current user
  // whose isEmailVerified flag is either true or false
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
