import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cpc_clean_user/core/theme/app_theme.dart';
import 'package:cpc_clean_user/features/auth/data/repositories/auth_repository.dart';
import 'package:cpc_clean_user/features/auth/cubit/auth_cubit.dart';
import 'package:cpc_clean_user/features/history/data/repositories/history_repository.dart';
import 'package:cpc_clean_user/features/orders/data/repositories/order_repository.dart';
import 'package:cpc_clean_user/core/routes/app_router.dart';
import 'package:cpc_clean_user/core/routes/routes.dart';

class CpcCleanUser extends StatelessWidget {
  final AppRouter appRouter;
  const CpcCleanUser({super.key, required this.appRouter});

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
          title: 'CPC Clean User',
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
