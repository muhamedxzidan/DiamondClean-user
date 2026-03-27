import 'package:flutter/material.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/features/orders/presentation/widgets/new_order_body.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.newOrderTitle)),
      body: const NewOrderBody(),
    );
  }
}
