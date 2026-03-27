import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// While login or session check is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Login succeeded — navigate to HomeScreen.
class AuthAuthenticated extends AuthState {
  final String agentName;
  final String carNumber;

  const AuthAuthenticated({required this.agentName, required this.carNumber});

  @override
  List<Object?> get props => [agentName, carNumber];
}

/// No session found — navigate to LoginScreen.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Session existed but the car was deactivated by admin.
class AuthDeactivated extends AuthState {
  const AuthDeactivated();
}

/// An error occurred during login.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
