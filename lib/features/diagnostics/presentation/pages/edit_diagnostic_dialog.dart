import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../domain/entities/diagnostic.dart';

class EditDiagnosticDialog extends StatefulWidget {
  final Diagnostic diagnostic;

  const EditDiagnosticDialog({
    super.key,
    required this.diagnostic,
  });

  @override
  State<EditDiagnosticDialog> createState() => _EditDiagnosticDialogState();
}

class _EditDiagnosticDialogState extends State<EditDiagnosticDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _codeController;
  late TextEditingController _descController;
  late TextEditingController _symptomsController;
  late TextEditingController _causeController;
  late TextEditingController _solutionController;
  late TextEditingController _technicianController;
  late TextEditingController _imagesController;
  late String _severity;
  late String _status;

  final List<String> _severityOptions = const ['منخفض', 'متوسط', 'عالي', 'حرج'];
  final List<String> _statusOptions = const ['قيد الانتظار', 'قيد المعالجة', 'تم الحل', 'مغلق'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.diagnostic.title);
    _subtitleController = TextEditingController(text: widget.diagnostic.subtitle ?? '');
    _codeController = TextEditingController(text: widget.diagnostic.diagnosticCode);
    _descController = TextEditingController(text: widget.diagnostic.description ?? '');
    _symptomsController = TextEditingController(text: widget.diagnostic.symptoms ?? '');
    _causeController = TextEditingController(text: widget.diagnostic.possibleCause ?? '');
    _solutionController = TextEditingController(text: widget.diagnostic.recommendedSolution ?? '');
    _technicianController = TextEditingController(text: widget.diagnostic.technicianName ?? '');
    _imagesController = TextEditingController(text: widget.diagnostic.images?.join(', ') ?? '');
    _severity = _severityOptions.contains(widget.diagnostic.severity)
        ? widget.diagnostic.severity
        : 'متوسط';
    _status = _statusOptions.contains(widget.diagnostic.status)
        ? widget.diagnostic.status
        : 'قيد الانتظار';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تعديل التشخيص',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              labelText: 'كود التشخيص *',
                              border: OutlineInputBorder(),
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
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان التشخيص *',
                        border: OutlineInputBorder(),
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
                              labelText: 'الحالة',
                              border: OutlineInputBorder(),
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _causeController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'السبب المحتمل',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _solutionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'الحل الموصى به والإجراء المتخذ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'الوصف التفصيلي',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imagesController,
                      decoration: const InputDecoration(
                        labelText: 'روابط الصور (مفصولة بفواصل)',
                        border: OutlineInputBorder(),
                        hintText: 'https://..., https://...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text('حفظ التعديلات'),
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
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final imgList = _imagesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updated = widget.diagnostic.copyWith(
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
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(updated);
  }
}
