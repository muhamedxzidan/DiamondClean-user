import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kimo_clean/core/theme/app_theme.dart';
import 'package:kimo_clean/features/auth/data/repositories/auth_repository.dart';
import 'package:kimo_clean/features/auth/cubit/auth_cubit.dart';
import 'package:kimo_clean/features/history/data/repositories/history_repository.dart';
import 'package:kimo_clean/features/orders/data/repositories/order_repository.dart';
import 'package:kimo_clean/core/routes/app_router.dart';
import 'package:kimo_clean/core/routes/routes.dart';

class KimoClean extends StatelessWidget {
  final AppRouter appRouter;
  const KimoClean({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => OrderRepository()),
        RepositoryProvider(create: (_) => HistoryRepository()),
      ],
      child: BlocProvider(
        create: (context) =>
            AuthCubit(authRepository: context.read<AuthRepository>()),
        child: MaterialApp(
          title: 'Kimo Clean',
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
