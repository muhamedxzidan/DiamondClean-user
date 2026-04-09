import 'package:flutter/material.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';
import 'package:diamond_clean_user/features/orders/presentation/widgets/new_order_body.dart';

class NewOrderScreen extends StatelessWidget {
  final String? initialLookupQuery;

  const NewOrderScreen({super.key, this.initialLookupQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.newOrderTitle)),
      body: NewOrderBody(initialLookupQuery: initialLookupQuery),
    );
  }
}
