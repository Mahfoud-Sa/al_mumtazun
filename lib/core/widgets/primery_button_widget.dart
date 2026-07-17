import 'package:engineering_ops_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PrimeryButtonWidget extends StatelessWidget {
  const PrimeryButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        hoverColor: Colors.white.withValues(alpha: 0.08),
        splashColor: Colors.white.withValues(alpha: 0.16),
        highlightColor: Colors.white.withValues(alpha: 0.05),

        onTap: () {},

        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),

          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 22, color: AppColors.secondary),

                SizedBox(width: 5),

                Text(
                  "اضافة جهاز جديد",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
