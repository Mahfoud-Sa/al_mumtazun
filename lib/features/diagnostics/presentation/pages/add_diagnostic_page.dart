import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/app_colors.dart';
import '../../domain/entities/diagnostic.dart';
import '../cubit/diagnostics_cubit.dart';

class AddDiagnosticPage extends StatefulWidget {
  const AddDiagnosticPage({super.key});

  @override
  State<AddDiagnosticPage> createState() => _AddDiagnosticPageState();
}

class _AddDiagnosticPageState extends State<AddDiagnosticPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _causeController = TextEditingController();
  final _solutionController = TextEditingController();
  final _technicianController = TextEditingController();
  final _imagesController = TextEditingController();

  String _severity = 'متوسط';
  String _status = 'قيد الانتظار';
  bool _isSaving = false;

  final List<String> _severityOptions = const ['منخفض', 'متوسط', 'عالي', 'حرج'];
  final List<String> _statusOptions = const ['قيد الانتظار', 'قيد المعالجة', 'تم الحل', 'مغلق'];

  @override
  void initState() {
    super.initState();
    _codeController.text = 'DIAG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _codeController.dispose();
    _descController.dispose();
    _symptomsController.dispose();
    _causeController.dispose();
    _solutionController.dispose();
    _technicianController.dispose();
    _imagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة تشخيص جديد'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 1,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'تفاصيل التشخيص الفني',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'أدخل المشكلة والأعراض والحلول التوصيدية للإجراءات الفنية.',
                          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                        ),
                        const Divider(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _codeController,
                                decoration: const InputDecoration(
                                  labelText: 'كود التشخيص *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.qr_code_outlined),
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _technicianController,
                                decoration: const InputDecoration(
                                  labelText: 'اسم الفني المختص',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'عنوان التشخيص الرئيسي *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title_outlined),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'عنوان التشخيص مطلوب' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _subtitleController,
                          decoration: const InputDecoration(
                            labelText: 'العنوان الفرعي / الملاحظة المختصرة',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.subtitles_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _severity,
                                decoration: const InputDecoration(
                                  labelText: 'مستوى الخطورة',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.report_problem_outlined),
                                ),
                                items: _severityOptions.map((sev) {
                                  return DropdownMenuItem(value: sev, child: Text(sev));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _severity = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _status,
                                decoration: const InputDecoration(
                                  labelText: 'الحالة الحالية',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.info_outline),
                                ),
                                items: _statusOptions.map((st) {
                                  return DropdownMenuItem(value: st, child: Text(st));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _status = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _symptomsController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'الأعراض الملاحظة',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _causeController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'السبب المحتمل',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _solutionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'الحل الموصى به والإجراء المتخذ',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'الوصف التفصيلي للمشكلة والتقرير الفني',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _imagesController,
                          decoration: const InputDecoration(
                            labelText: 'روابط الصور الإيضاحية (مفصولة بفواصل)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.image_outlined),
                            hintText: 'https://..., https://...',
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              ),
                              child: const Text('إلغاء'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: _isSaving ? null : _save,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ التشخيص'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final imgList = _imagesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final newDiagnostic = Diagnostic(
      id: 0,
      diagnosticCode: _codeController.text.trim(),
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty ? null : _subtitleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      symptoms: _symptomsController.text.trim().isEmpty ? null : _symptomsController.text.trim(),
      possibleCause: _causeController.text.trim().isEmpty ? null : _causeController.text.trim(),
      recommendedSolution: _solutionController.text.trim().isEmpty ? null : _solutionController.text.trim(),
      technicianName: _technicianController.text.trim().isEmpty ? null : _technicianController.text.trim(),
      images: imgList.isEmpty ? null : imgList,
      severity: _severity,
      status: _status,
      createdAt: DateTime.now(),
    );

    final success = await context.read<DiagnosticsCubit>().addDiagnostic(newDiagnostic);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء حفظ التشخيص.')),
        );
      }
    }
  }
}
