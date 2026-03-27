import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/features/auth/cubit/auth_cubit.dart';
import 'package:kimo_clean/features/auth/cubit/auth_state.dart';
import 'package:kimo_clean/core/routes/routes.dart';
import 'package:kimo_clean/core/theme/app_colors.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _agentNameController = TextEditingController();
  final _carNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _agentNameController.dispose();
    _carNumberController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
      agentName: _agentNameController.text.trim(),
      carNumber: _carNumberController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        final wasLoading = previous is AuthLoading;
        final isNowLoading = current is AuthLoading;
        return wasLoading != isNowLoading;
      },
      listener: (context, state) {
        switch (state) {
          case AuthAuthenticated():
            Navigator.of(context).pushReplacementNamed(Routes.home);

          case AuthError(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
              ),
            );

          default:
            break;
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Agent Name ──
              TextFormField(
                controller: _agentNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: AppStrings.agentNameLabel,
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.agentNameValidation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Car Number ──
              TextFormField(
                controller: _carNumberController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: AppStrings.carNumberLabel,
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.carNumberValidation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Password ──
              ValueListenableBuilder<bool>(
                valueListenable: _obscurePassword,
                builder: (context, obscure, child) {
                  return TextFormField(
                    controller: _passwordController,
                    obscureText: obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onLoginPressed(),
                    decoration: InputDecoration(
                      labelText: AppStrings.passwordLabel,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          _obscurePassword.value = !obscure;
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.passwordValidation;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // ── Login Button ──
              ElevatedButton(
                onPressed: isLoading ? null : _onLoginPressed,
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.surfaceWhite,
                        ),
                      )
                    : const Text(AppStrings.loginButton),
              ),
            ],
          ),
        );
      },
    );
  }
}
