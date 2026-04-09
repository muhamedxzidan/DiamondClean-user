import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean_user/core/constants/app_strings.dart';
import 'package:diamond_clean_user/features/auth/data/repositories/auth_repository.dart';
import 'package:diamond_clean_user/features/auth/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial());

  /// Called on app startup (SplashScreen) to verify the saved session.
  Future<void> checkSession() async {
    emit(const AuthLoading());

    try {
      final results = await Future.wait([
        _authRepository.getSavedAgentName(),
        _authRepository.getSavedCarNumber(),
      ]);
      final agentName = results[0];
      final carNumber = results[1];

      if (carNumber == null || carNumber.isEmpty) {
        emit(const AuthUnauthenticated());
        return;
      }

      final isActive = await _authRepository
          .checkCarStatus(carNumber)
          .timeout(const Duration(seconds: 10));

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
        await _authRepository.logout();
        emit(const AuthDeactivated());
      }
    } on TimeoutException {
      emit(const AuthUnauthenticated());
    } catch (_) {
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
    } catch (_) {
      emit(const AuthError(AppStrings.unexpectedError));
    }
  }

  /// Logs the user out and clears saved credentials.
  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
