import 'package:flutter/material.dart';
import 'package:cpc_clean_user/core/constants/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cpc_clean_user/core/routes/routes.dart';
import 'package:cpc_clean_user/features/auth/presentation/screens/splash_screen.dart';
import 'package:cpc_clean_user/features/auth/presentation/screens/login_screen.dart';
import 'package:cpc_clean_user/features/home/presentation/screens/home_screen.dart';
import 'package:cpc_clean_user/features/orders/presentation/screens/new_order_screen.dart';
import 'package:cpc_clean_user/features/orders/cubit/new_order_cubit.dart';
import 'package:cpc_clean_user/features/orders/data/repositories/order_repository.dart';
import 'package:cpc_clean_user/features/auth/data/repositories/auth_repository.dart';
import 'package:cpc_clean_user/features/history/presentation/screens/daily_history_screen.dart';
import 'package:cpc_clean_user/features/history/cubit/history_cubit.dart';
import 'package:cpc_clean_user/features/history/data/repositories/history_repository.dart';
import 'package:cpc_clean_user/features/history/data/models/order_model.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case Routes.newOrder:
        final initialLookupQuery = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (ctx) => NewOrderCubit(
              authRepository: ctx.read<AuthRepository>(),
              orderRepository: ctx.read<OrderRepository>(),
            ),
            child: NewOrderScreen(initialLookupQuery: initialLookupQuery),
          ),
        );

      case Routes.dailyHistory:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (ctx) => HistoryCubit(
              historyRepository: ctx.read<HistoryRepository>(),
              authRepository: ctx.read<AuthRepository>(),
            )..loadTodayOrders(),
            child: const DailyHistoryScreen(),
          ),
        );

      case Routes.orderDetails:
        // Example of handling arguments routing with an OrderModel
        if (settings.arguments is OrderModel) {
          final order = settings.arguments as OrderModel;
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text(AppStrings.orderDetailsTitle)),
              body: Center(
                child: Text(
                  '${AppStrings.orderNumberPrefix} ${order.serialNumber}',
                ),
              ),
            ),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  Route _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.errorTitle)),
        body: const Center(child: Text(AppStrings.pageNotFound)),
      ),
    );
  }
}
