import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:diamond_clean_user/core/theme/app_theme.dart';
import 'package:diamond_clean_user/features/auth/data/repositories/auth_repository.dart';
import 'package:diamond_clean_user/features/auth/cubit/auth_cubit.dart';
import 'package:diamond_clean_user/features/history/data/repositories/history_repository.dart';
import 'package:diamond_clean_user/features/orders/cubit/category_cubit.dart';
import 'package:diamond_clean_user/features/orders/data/repositories/category_repository.dart';
import 'package:diamond_clean_user/features/orders/data/repositories/order_repository.dart';
import 'package:diamond_clean_user/core/routes/app_router.dart';
import 'package:diamond_clean_user/core/routes/routes.dart';

class DiamondCleanUser extends StatelessWidget {
  final AppRouter appRouter;
  const DiamondCleanUser({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => OrderRepository()),
        RepositoryProvider(create: (_) => HistoryRepository()),
        RepositoryProvider(create: (_) => CategoryRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => CategoryCubit(
              categoryRepository: context.read<CategoryRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Diamond clean',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', 'EG')],
          locale: const Locale('ar', 'EG'),
          onGenerateRoute: appRouter.generateRoute,
          initialRoute: Routes.splash,
        ),
      ),
    );
  }
}
