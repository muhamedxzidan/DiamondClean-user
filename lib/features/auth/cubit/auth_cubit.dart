import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cpc_clean_user/features/auth/data/repositories/auth_repository.dart';
import 'package:cpc_clean_user/features/auth/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial());

  /// Called on app startup (SplashScreen) to verify the saved session.
  Future<void> checkSession() async {
    emit(const AuthLoading());

    try {
      final agentName = await _authRepository.getSavedAgentName();
      final carNumber = await _authRepository.getSavedCarNumber();

      // No saved session → go to login
      if (carNumber == null || carNumber.isEmpty) {
        emit(const AuthUnauthenticated());
        return;
      }

      // Session exists → verify car is still active
      final isActive = await _authRepository.checkCarStatus(carNumber);

      if (isActive) {
        emit(
          AuthAuthenticated(
            agentName: (agentName == null || agentName.isEmpty)
                ? '---'
                : agentName,
            carNumber: carNumber,
          ),
        );
      } else {
        // Admin deactivated the car → force logout
        await _authRepository.logout();
        emit(const AuthDeactivated());
      }
    } catch (_) {
      // Fail-safe: if anything goes wrong, send to login
      emit(const AuthUnauthenticated());
    }
  }

  /// Performs login with the provided credentials.
  Future<void> login({
    required String agentName,
    required String carNumber,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      await _authRepository.login(
        agentName: agentName,
        carNumber: carNumber,
        password: password,
      );
      emit(AuthAuthenticated(agentName: agentName, carNumber: carNumber));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    }
  }

  /// Logs the user out and clears saved credentials.
  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
