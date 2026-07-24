import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../domain/entities/diagnostic.dart';

class DeleteDiagnosticDialog extends StatelessWidget {
  final Diagnostic diagnostic;

  const DeleteDiagnosticDialog({
    super.key,
    required this.diagnostic,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 8),
            Text(
              'حذف التشخيص',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت تأكد من رغبتك في حذف التشخيص "${diagnostic.title}" (كود: ${diagnostic.diagnosticCode})؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
