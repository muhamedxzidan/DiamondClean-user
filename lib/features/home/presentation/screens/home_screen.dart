import 'package:flutter/material.dart';
import 'package:kimo_clean/features/home/presentation/widgets/home_drawer.dart';
import 'package:kimo_clean/features/home/presentation/widgets/new_order_button.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeTitle)),
      drawer: const HomeDrawer(),
      body: const SafeArea(child: Center(child: NewOrderButton())),
    );
  }
}
