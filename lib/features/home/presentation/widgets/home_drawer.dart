import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cpc_clean_user/core/constants/app_strings.dart';
import 'package:cpc_clean_user/features/auth/cubit/auth_cubit.dart';
import 'package:cpc_clean_user/features/auth/cubit/auth_state.dart';
import 'package:cpc_clean_user/core/routes/routes.dart';
import 'package:cpc_clean_user/core/theme/app_colors.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _DrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text(AppStrings.drawerNewOrder),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.newOrder);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text(AppStrings.drawerDailyOrders),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.dailyHistory);
                  },
                ),
                const Divider(),
                _LogoutTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays the agent name and car number from secure storage.
class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (previous is AuthAuthenticated && current is AuthAuthenticated) {
          return previous.agentName != current.agentName ||
              previous.carNumber != current.carNumber;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final agentName = switch (state) {
          AuthAuthenticated(:final agentName) => agentName,
          _ => AppStrings.unknown,
        };

        final carNumber = switch (state) {
          AuthAuthenticated(:final carNumber) => carNumber,
          _ => AppStrings.unknown,
        };

        return UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: AppColors.surfaceWhite,
            child: Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          accountName: Text(
            agentName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          accountEmail: Text(
            '${AppStrings.carPrefix} $carNumber',
            style: const TextStyle(fontSize: 14),
          ),
        );
      },
    );
  }
}

/// Logout tile that clears secure storage via AuthCubit.
class _LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.login, (_) => false);
        }
      },
      child: ListTile(
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: const Text(
          AppStrings.drawerLogout,
          style: TextStyle(color: AppColors.error),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer first
          context.read<AuthCubit>().logout();
        },
      ),
    );
  }
}
