import 'package:flutter/material.dart';
import 'package:cpc_clean_user/core/constants/app_strings.dart';
import 'package:cpc_clean_user/features/history/presentation/widgets/daily_history_body.dart';

class DailyHistoryScreen extends StatelessWidget {
  const DailyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.dailyArchiveTitle)),
      body: const DailyHistoryBody(),
    );
  }
}
