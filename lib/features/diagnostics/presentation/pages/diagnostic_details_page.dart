import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/app_colors.dart';
import '../../domain/entities/diagnostic.dart';
import '../cubit/diagnostics_cubit.dart';
import 'delete_diagnostic_dialog.dart';
import 'edit_diagnostic_dialog.dart';

String _formatDate(DateTime dt) {
  final y = dt.year;
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y/$m/$d - $hh:$mm';
}

class DiagnosticDetailsPage extends StatefulWidget {
  final Diagnostic diagnostic;

  const DiagnosticDetailsPage({
    super.key,
    required this.diagnostic,
  });

  @override
  State<DiagnosticDetailsPage> createState() => _DiagnosticDetailsPageState();
}

class _DiagnosticDetailsPageState extends State<DiagnosticDetailsPage> {
  late Diagnostic _currentDiagnostic;

  @override
  void initState() {
    super.initState();
    _currentDiagnostic = widget.diagnostic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل التشخيص: ${_currentDiagnostic.diagnosticCode}'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            tooltip: 'تعديل',
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: _openEdit,
          ),
          IconButton(
            tooltip: 'حذف',
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentDiagnostic.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if (_currentDiagnostic.subtitle != null &&
                                        _currentDiagnostic.subtitle!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        _currentDiagnostic.subtitle!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _SeverityBadge(severity: _currentDiagnostic.severity),
                                  const SizedBox(height: 8),
                                  _StatusBadge(status: _currentDiagnostic.status),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Wrap(
                            spacing: 24,
                            runSpacing: 12,
                            children: [
                              _InfoItem(
                                icon: Icons.qr_code_outlined,
                                label: 'الكود الفني',
                                value: _currentDiagnostic.diagnosticCode,
                              ),
                              _InfoItem(
                                icon: Icons.person_outline,
                                label: 'الفني المختص',
                                value: _currentDiagnostic.technicianName ?? 'غير محدد',
                              ),
                              _InfoItem(
                                icon: Icons.calendar_today_outlined,
                                label: 'تاريخ الإنشاء',
                                value: _formatDate(_currentDiagnostic.createdAt),
                              ),
                              if (_currentDiagnostic.updatedAt != null)
                                _InfoItem(
                                  icon: Icons.update_outlined,
                                  label: 'آخر تحديث',
                                  value: _formatDate(_currentDiagnostic.updatedAt!),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Diagnostic Details Cards
                  if (_currentDiagnostic.symptoms != null &&
                      _currentDiagnostic.symptoms!.isNotEmpty)
                    _DetailSectionCard(
                      title: 'الأعراض الملاحظة',
                      icon: Icons.error_outline,
                      iconColor: Colors.orange,
                      content: _currentDiagnostic.symptoms!,
                    ),

                  if (_currentDiagnostic.possibleCause != null &&
                      _currentDiagnostic.possibleCause!.isNotEmpty)
                    _DetailSectionCard(
                      title: 'السبب المحتمل',
                      icon: Icons.psychology_outlined,
                      iconColor: Colors.purple,
                      content: _currentDiagnostic.possibleCause!,
                    ),

                  if (_currentDiagnostic.recommendedSolution != null &&
                      _currentDiagnostic.recommendedSolution!.isNotEmpty)
                    _DetailSectionCard(
                      title: 'الحل الموصى به والإجراء المتخذ',
                      icon: Icons.build_circle_outlined,
                      iconColor: Colors.green,
                      content: _currentDiagnostic.recommendedSolution!,
                    ),

                  if (_currentDiagnostic.description != null &&
                      _currentDiagnostic.description!.isNotEmpty)
                    _DetailSectionCard(
                      title: 'الوصف التفصيلي والتقرير الفني',
                      icon: Icons.description_outlined,
                      iconColor: AppColors.primary,
                      content: _currentDiagnostic.description!,
                    ),

                  // Images section
                  if (_currentDiagnostic.images != null &&
                      _currentDiagnostic.images!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.image_outlined, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'الصور والمرفقات الفنية',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _currentDiagnostic.images!.map((url) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    width: 160,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 160,
                                        height: 120,
                                        color: Colors.grey.shade300,
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, color: Colors.grey),
                                            SizedBox(height: 4),
                                            Text(
                                              'تعذر تحميل الصورة',
                                              style: TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit() async {
    final updated = await showDialog<Diagnostic>(
      context: context,
      builder: (_) => EditDiagnosticDialog(diagnostic: _currentDiagnostic),
    );

    if (updated != null && mounted) {
      final cubit = context.read<DiagnosticsCubit>();
      final success = await cubit.editDiagnostic(updated);
      if (success && mounted) {
        setState(() => _currentDiagnostic = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث التقرير بنجاح.')),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDiagnosticDialog(diagnostic: _currentDiagnostic),
    );

    if (confirm == true && mounted) {
      final cubit = context.read<DiagnosticsCubit>();
      final success = await cubit.removeDiagnostic(_currentDiagnostic.id);
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}

class _DetailSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String content;

  const _DetailSectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (severity) {
      case 'حرج':
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
      case 'عالي':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        break;
      case 'متوسط':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        break;
      case 'منخفض':
      default:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'الخطورة: $severity',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case 'تم الحل':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      case 'مغلق':
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
        break;
      case 'قيد المعالجة':
        bg = Colors.lightBlue.shade100;
        fg = Colors.lightBlue.shade900;
        break;
      case 'قيد الانتظار':
      default:
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'الحالة: $status',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
