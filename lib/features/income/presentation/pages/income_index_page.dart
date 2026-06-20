import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../income_screen.dart'; // Reuse the existing income entry form screen

class IncomeIndexPage extends StatelessWidget {
  const IncomeIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we show a simple placeholder list.
    // In a full implementation, this would fetch incomes via a Bloc or use case.
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('قائمة الإيرادات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'لا توجد إيرادات مُسجلة بعد.',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () {
          // Navigate to the existing IncomeScreen which contains the add form.
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IncomeScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة إيراد'),
      ),
    );
  }
}
