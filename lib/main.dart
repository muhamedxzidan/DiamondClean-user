import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:diamond_clean_user/core/routes/app_router.dart';
import 'package:diamond_clean_user/diamond_clean_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Concurrently execute heavy initializations to minimize blocking time before runApp
  final results = await Future.wait([
    Firebase.initializeApp(),
    _checkJailbreak(),
  ]);

  final bool jailbroken = results[1] as bool;
  if (jailbroken) {
    exit(0);
  }

  final appRouter = AppRouter();
  runApp(MyApp(appRouter: appRouter));
}

Future<bool> _checkJailbreak() async {
  try {
    return await FlutterJailbreakDetection.jailbroken;
  } on PlatformException {
    return true; // Fail-deadly
  }
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return DiamondCleanUser(appRouter: appRouter);
  }
}
