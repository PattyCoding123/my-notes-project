import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

// AuthBloc handles AuthEvents and what states should be emitted from
// certain AuthEvents. Each on<Event> is defined for each AuthEvent.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // Should register event
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    // Forgot password event
    on<AuthEventForgotPassword>((event, emit) async {
      // Initial state of AuthStateForgotPassword where user is idling
      // in the ForgotPasswordView.
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));

      final email = event.email;
      if (email == null) {
        return; // The user just wanted to go to the forgot-password screen.
      }

      // The user wants to actually send a forgot-password email.
      // Begin the loading screen.
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      // End the loading screen.
      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false,
      ));
    });

    // Send email verification event
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        // Stay on whatever state we are at during the sendEmailVerification
        // event, which should be the AuthStateNeedsVerification state.
        emit(state);
      },
    );

    // Register event
    on<AuthEventRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.createUser(
            email: email,
            password: password,
          );
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateRegistering(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );

    // Initialize event
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      },
    );

    // Log in event
    on<AuthEventLogIn>(
      (event, emit) async {
        // Enable Loading screen to show that the authentication service
        // is trying to log in the user.
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while we log you in...',
        ));
        // AuthEventLogIn has an email and password member which we
        // will use to try and log in with the authentication service.
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );
          if (!user.isEmailVerified) {
            // If user is not verified, then the AuthBloc will emit the
            // AuthStateLoggedOut state without any exception and no loading
            // indication which disables the loading screen, and then
            // it will emit the AuthStateNeedsVerification state.
            emit(const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ));
            emit(const AuthStateNeedsVerification(isLoading: false));
          } else {
            // If the user is verified, then the AuthBloc will emit
            // the AuthStateLoggedOut state with no exception or loading
            // indication which disables the loading screen, and then
            // it will emit the AuthStateLoggedIn state.
            emit(const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ));
            emit(AuthStateLoggedIn(
              user: user,
              isLoading: false,
            ));
          }
        } on Exception catch (e) {
          // On an exception, emit the AuthStateLoggedOut state
          // with no exception or loading indication.
          emit(AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );

    // Log out event
    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          // If user logs out successfully, emit the AuthStateLoggedOut state
          // with no exception and loading indicator as false.
          await provider.logOut();
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } on Exception catch (e) {
          // If user cannot log out, emit the AuthStateLoggedOut state with
          // an exception and loading indicator as false.
          emit(
            AuthStateLoggedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      },
    );
  }
}
