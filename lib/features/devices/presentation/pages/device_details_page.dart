import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../compounds/domain/entities/compound.dart';
import '../../../compounds/presentation/cubit/compounds_cubit.dart';
import '../../../compounds/presentation/cubit/compounds_state.dart';
import '../../../invoices/presentation/pages/invoice_details_page.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_user.dart';
import '../../../invoices/domain/entities/invoice_item.dart';
import '../device_status_presentation.dart';
import '../cubit/device_details_cubit.dart';
import '../cubit/device_details_state.dart';

class DeviceDetailsPage extends StatelessWidget {
  final Device device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeviceDetailsCubit>(param1: device)..loadInvoice(),
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: _DeviceDetailsView(),
      ),
    );
  }
}

class _DeviceDetailsView extends StatelessWidget {
  const _DeviceDetailsView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('تفاصيل الجهاز'),
        leading: IconButton(
          tooltip: 'رجوع',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
            buildWhen: (previous, current) =>
                previous.invoice != current.invoice ||
                previous.isLoadingInvoice != current.isLoadingInvoice,
            builder: (context, state) {
              final invoice = state.invoice;
              final canOpenInvoice = invoice != null && !state.isLoadingInvoice;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton.icon(
                  onPressed: canOpenInvoice
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                InvoiceDetailsPage(invoice: invoice),
                          ),
                        )
                      : null,
                  icon: const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    state.isLoadingInvoice
                        ? 'جاري التحقق...'
                        : 'الانتقال الى الفاتورة',
                    style: AppTextStyles.label.copyWith(
                      color: canOpenInvoice ? Colors.white : Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: canOpenInvoice
                        ? Colors.white
                        : colorScheme.primary,
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
                    backgroundColor: canOpenInvoice
                        ? colorScheme.primary
                        : Colors.transparent,
                    side: BorderSide(
                      color: canOpenInvoice
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                  ),
                ),
              );
            },
          ),
          // IconButton(
          //   tooltip: 'حفظ',
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('تم حفظ التعديلات محليا')),
          //     );
          //   },
          //   icon: const Icon(Icons.save_outlined),
          // ),
          const SizedBox(width: AppSpacing.sm),
        ],
        shape: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      body: SafeArea(
        child: BlocListener<DeviceDetailsCubit, DeviceDetailsState>(
          listenWhen: (previous, current) =>
              (previous.statusErrorMessage != current.statusErrorMessage &&
                  current.statusErrorMessage != null) ||
              (previous.engineerNoteErrorMessage !=
                      current.engineerNoteErrorMessage &&
                  current.engineerNoteErrorMessage != null) ||
              (previous.isSavingEngineerNote &&
                  !current.isSavingEngineerNote &&
                  current.engineerNoteErrorMessage == null) ||
              (previous.invoiceErrorMessage != current.invoiceErrorMessage &&
                  current.invoiceErrorMessage != null) ||
              (!previous.invoiceCreated && current.invoiceCreated),
          listener: (context, state) {
            final message =
                state.statusErrorMessage ??
                state.engineerNoteErrorMessage ??
                state.invoiceErrorMessage;
            if (message == null && !state.invoiceCreated) {
              showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('تم الحفظ'),
                  content: const Text('تم حفظ الملاحظة بنجاح'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('حسنا'),
                    ),
                  ],
                ),
              );
              return;
            }

            if (message == null && state.invoiceCreated) {
              final invoice = state.invoice;
              showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('تم إنشاء الفاتورة'),
                  content: const Text('تم حفظ الفاتورة بنجاح'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('حسنا'),
                    ),
                    if (invoice != null)
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  InvoiceDetailsPage(invoice: invoice),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('عرض الفاتورة'),
                      ),
                  ],
                ),
              );
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message ?? 'تم تصدير الفاتورة بنجاح'),
                backgroundColor: message == null
                    ? Colors.green
                    : colorScheme.error,
              ),
            );
          },
          child: BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        _StatusAssignmentCard(),
                        SizedBox(height: AppSpacing.xl),
                        // _DeviceOverviewCard(),
                        // SizedBox(height: AppSpacing.xl),
                        _TechnicalLogisticsSection(),
                        SizedBox(height: AppSpacing.xl),
                        _EngineerNotesSection(),

                        SizedBox(height: AppSpacing.xl),
                        _DiagnosticsSection(),
                        SizedBox(height: AppSpacing.xl),
                        _BillingSection(),
                        SizedBox(height: AppSpacing.xl),
                        // _ActivityLogSection(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusAssignmentCard extends StatelessWidget {
  const _StatusAssignmentCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
      builder: (context, state) {
        return _IndustrialCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الحالة الحالية', style: AppTextStyles.label),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: state.status.indicatorColor(context),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.xs,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              state.status.label,
                              style: AppTextStyles.sectionHeading.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<DeviceStatus>(
                    enabled: !state.isChangingStatus,
                    onSelected: context.read<DeviceDetailsCubit>().changeStatus,
                    itemBuilder: (context) => DeviceStatus.values
                        .map(
                          (status) => PopupMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                    child: IgnorePointer(
                      child: ElevatedButton(
                        onPressed: state.isChangingStatus ? null : () {},
                        child: state.isChangingStatus
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('تغيير الحالة'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.lg),
              Text('المهندس المسؤول', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              _EngineerPickerField(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _DeviceOverviewCard extends StatelessWidget {
  const _DeviceOverviewCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
      builder: (context, state) {
        final device = state.device;
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 160,
                color: colorScheme.primary,
                padding: const EdgeInsets.all(AppSpacing.xl),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.precision_manufacturing_outlined,
                      color: Colors.white.withValues(alpha: 0.72),
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Text(
                    //   device.name.isEmpty ? 'جهاز غير مسمى' : device.name,
                    //   style: AppTextStyles.sectionHeading.copyWith(
                    //     color: Colors.white,
                    //   ),
                    // ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'رقم الجهاز ${device.id}',
                      style: AppTextStyles.label.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EngineerPickerField extends StatelessWidget {
  final DeviceDetailsState state;

  const _EngineerPickerField({required this.state});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showEngineerPicker(context),
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: InputDecorator(
        decoration: const InputDecoration(suffixIcon: Icon(Icons.expand_more)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.assignedEngineer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body,
              ),
            ),
            if (state.assignedEngineerId != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text('#${state.assignedEngineerId}', style: AppTextStyles.label),
            ],
          ],
        ),
      ),
    );
  }

  void _showEngineerPicker(BuildContext context) {
    final cubit = context.read<DeviceDetailsCubit>();
    if (cubit.state.users.isEmpty && !cubit.state.isLoadingUsers) {
      cubit.loadUsers(refresh: true);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const _EngineerPickerSheet()),
    );
  }
}

class _EngineerPickerSheet extends StatefulWidget {
  const _EngineerPickerSheet();

  @override
  State<_EngineerPickerSheet> createState() => _EngineerPickerSheetState();
}

class _EngineerPickerSheetState extends State<_EngineerPickerSheet> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      context.read<DeviceDetailsCubit>().loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'اختيار المهندس المسؤول',
                      style: AppTextStyles.sectionHeading,
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
                builder: (context, state) {
                  if (state.isLoadingUsers && state.users.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.usersErrorMessage != null && state.users.isEmpty) {
                    return _UsersErrorView(message: state.usersErrorMessage!);
                  }

                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<DeviceDetailsCubit>()
                        .loadUsers(refresh: true),
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount:
                          state.users.length +
                          (state.isLoadingMoreUsers ? 1 : 0),
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        if (index >= state.users.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final user = state.users[index];
                        return _EngineerUserTile(
                          user: user,
                          selected: user.id == state.assignedEngineerId,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngineerUserTile extends StatelessWidget {
  final DeviceUser user;
  final bool selected;

  const _EngineerUserTile({required this.user, required this.selected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      onTap: () {
        context.read<DeviceDetailsCubit>().assignEngineer(user);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerLow,
          border: Border.all(
            color: selected
                ? colorScheme.secondary
                : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.person_outline,
              color: selected
                  ? colorScheme.secondary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTextStyles.labelStrong.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    [
                      if (user.role.isNotEmpty) user.role,
                      if (user.phoneNumber.isNotEmpty) user.phoneNumber,
                    ].join(' • '),
                    style: AppTextStyles.label.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '#${user.id}',
              style: AppTextStyles.label.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersErrorView extends StatelessWidget {
  final String message;

  const _UsersErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 36),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<DeviceDetailsCubit>().loadUsers(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechnicalLogisticsSection extends StatelessWidget {
  const _TechnicalLogisticsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
      builder: (context, state) {
        final device = state.device;
        return _Section(
          title: 'المعلومات الفنية واللوجستية',
          child: Column(
            children: [
              _InfoRow(label: 'العميل', value: device.customerName),
              _InfoRow(
                label: 'الماركة / الموديل',
                value: '${device.brand} / ${device.model}',
              ),
              _InfoRow(
                label: 'تاريخ الاستلام',
                value: _formatDate(device.createdAt),
              ),
              _EditableDateRow(date: state.deliveryDate),
              // _InfoRow(
              //   label: 'أرقام الهاتف',
              //   value: device.phoneNumbers.isEmpty
              //       ? '-'
              //       : device.phoneNumbers.join('، '),
              // ),
            ],
          ),
        );
      },
    );
  }
}

class _EditableDateRow extends StatelessWidget {
  final DateTime? date;

  const _EditableDateRow({required this.date});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null && context.mounted) {
          context.read<DeviceDetailsCubit>().updateDeliveryDate(picked);
        }
      },
      child: _InfoRow(
        label: 'تاريخ التسليم',
        value: date == null ? 'غير محدد' : _formatDate(date!),
        trailing: const Icon(Icons.edit_calendar_outlined, size: 18),
      ),
    );
  }
}

class _DiagnosticsSection extends StatefulWidget {
  const _DiagnosticsSection();

  @override
  State<_DiagnosticsSection> createState() => _DiagnosticsSectionState();
}

class _DiagnosticsSectionState extends State<_DiagnosticsSection> {
  final TextEditingController _noteController = TextEditingController();
  String _draftNote = '';
  bool _loadedInitialNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedInitialNote) return;

    final note = context.read<DeviceDetailsCubit>().state.device.engineerNote;
    _noteController.text = note;
    _draftNote = note;
    _loadedInitialNote = true;
  }

  Future<void> _submitNote() async {
    final note = _draftNote.trim();
    if (note.isEmpty) return;

    await context.read<DeviceDetailsCubit>().addEngineerNote(note);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
      builder: (context, state) {
        return _Section(
          title: 'التشخيص والملاحظات',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              _EngineerNoteInput(
                controller: _noteController,
                value: _draftNote,
                isSaving: state.isSavingEngineerNote,
                onChanged: (value) => setState(() => _draftNote = value),
                onSubmit: _submitNote,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EngineerNoteInput extends StatelessWidget {
  final TextEditingController controller;
  final String value;
  final bool isSaving;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const _EngineerNoteInput({
    required this.controller,
    required this.value,
    required this.isSaving,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final canSubmit = value.trim().isNotEmpty && !isSaving;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ملاحظات المهندس',
            style: AppTextStyles.labelStrong.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            maxLines: 4,
            onChanged: onChanged,
            textInputAction: TextInputAction.newline,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظة جديدة...',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              filled: true,
              fillColor: colorScheme.surface,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.secondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: ElevatedButton.icon(
              onPressed: canSubmit ? onSubmit : null,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ الملاحظة'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineerNotesSection extends StatelessWidget {
  const _EngineerNotesSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
      builder: (context, state) {
        return _Section(
          title: 'ملاحظات الجهاز ',
          child: Column(children: [_EngineerNoteCard(note: state.device)]),
        );
      },
    );
  }
}

class _EngineerNoteCard extends StatelessWidget {
  final Device note;

  const _EngineerNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "وصف المشكلة",
                  style: AppTextStyles.labelStrong.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Text(_formatDateTime(note.createdAt), style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            note.problemDescription,
            style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  "ملاحظات داخلية",
                  style: AppTextStyles.labelStrong.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Text(_formatDateTime(note.createdAt), style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            note.internalNotes.isEmpty
                ? 'لا توجد ملاحظات داخلية'
                : note.internalNotes,
            style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _BillingSection extends StatelessWidget {
  const _BillingSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
      builder: (context, state) {
        return _Section(
          title: 'الإصلاحات والمتطلبات',
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  color: colorScheme.surfaceContainerLow,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "القطع المراد تبديلها / إصلاحها",
                          style: AppTextStyles.labelStrong,
                        ),
                      ),
                      Text('السعر', style: AppTextStyles.labelStrong),
                    ],
                  ),
                ),
                for (var index = 0; index < state.invoiceItems.length; index++)
                  _InvoiceItemRow(
                    item: state.invoiceItems[index],
                    onQuantityChanged: (quantity) => context
                        .read<DeviceDetailsCubit>()
                        .updateInvoiceItemQuantity(index, quantity),
                    onRemove: () => context
                        .read<DeviceDetailsCubit>()
                        .removeInvoiceItem(index),
                  ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await showDialog<Compound>(
                      context: context,
                      builder: (_) => BlocProvider(
                        create: (_) =>
                            getIt<CompoundsCubit>()..fetch(size: 100),
                        child: const SparePartPickerDialog(),
                      ),
                    );

                    if (result != null && context.mounted) {
                      context.read<DeviceDetailsCubit>().addInvoiceItem(
                        InvoiceItem(
                          id: 0,
                          invoiceId: 0,
                          sparePartId: result.id,
                          sparePartName: result.name,
                          quantity: 1,
                          unitPrice: result.sellPrice,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('إضافة قطعة'),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _MoneyField(
                        label: 'أجرة الصيانة',
                        value: state.repairLaborPrice,
                        onChanged: context
                            .read<DeviceDetailsCubit>()
                            .updateRepairLaborPrice,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _MoneyField(
                        label: 'تكاليف إضافية',
                        value: state.additionalCosts,
                        onChanged: context
                            .read<DeviceDetailsCubit>()
                            .updateAdditionalCosts,
                      ),
                      _MoneyField(
                        label: "خصم للعميل",
                        value: state.discount,
                        accentColor: colorScheme.error,
                        onChanged: context
                            .read<DeviceDetailsCubit>()
                            .updateDiscount,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'إجمالي الفاتورة',
                              style: AppTextStyles.sectionHeading,
                            ),
                          ),
                          Text(
                            _formatMoney(state.totalBill),
                            style: AppTextStyles.sectionHeading.copyWith(
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              state.isLoadingInvoice || state.isCreatingInvoice
                              ? null
                              : context
                                    .read<DeviceDetailsCubit>()
                                    .exportInvoice,
                          icon:
                              state.isLoadingInvoice || state.isCreatingInvoice
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  state.invoice == null
                                      ? Icons.description_outlined
                                      : Icons.edit_document,
                                ),
                          label: Text(
                            state.isLoadingInvoice
                                ? 'جاري التحقق من الفاتورة...'
                                : state.isCreatingInvoice
                                ? state.invoice == null
                                      ? 'جاري إنشاء الفاتورة...'
                                      : 'جاري تحديث الفاتورة...'
                                : state.invoice == null
                                ? 'إنشاء الفاتورة'
                                : 'تحديث الفاتورة',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InvoiceItemRow extends StatelessWidget {
  final InvoiceItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _InvoiceItemRow({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings_outlined, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.sparePartName,
              style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
            ),
          ),
          IconButton(
            tooltip: 'تقليل الكمية',
            onPressed: () => onQuantityChanged(item.quantity - 1),
            icon: const Icon(Icons.remove_circle_outline, size: 18),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              '${item.quantity}x',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(color: colorScheme.onSurface),
            ),
          ),
          IconButton(
            tooltip: 'زيادة الكمية',
            onPressed: () => onQuantityChanged(item.quantity + 1),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _formatMoney(item.total),
            style: AppTextStyles.labelStrong.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'حذف المادة',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 18),
            color: colorScheme.error,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _MoneyField extends StatefulWidget {
  final String label;
  final double value;
  final Color? accentColor;
  final ValueChanged<String> onChanged;

  const _MoneyField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.accentColor,
  });

  @override
  State<_MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<_MoneyField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formattedValue);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _MoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode.hasFocus) return;

    final nextText = _formattedValue;
    if (_controller.text == nextText) return;
    _controller.text = nextText;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _formattedValue => widget.value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = widget.accentColor;
    final content = Row(
      children: [
        Expanded(
          child: Text(
            widget.label,
            style: AppTextStyles.body.copyWith(
              color: accentColor ?? colorScheme.onSurface,
              fontWeight: accentColor == null ? null : FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 120,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
            onChanged: widget.onChanged,
            style: TextStyle(color: accentColor ?? colorScheme.onSurface),
            decoration: InputDecoration(
              suffixText: ' ريال يمني',
              suffixStyle: TextStyle(
                color: accentColor ?? colorScheme.onSurfaceVariant,
              ),
              focusedBorder: accentColor == null
                  ? null
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor),
                    ),
              enabledBorder: accentColor == null
                  ? null
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                        color: accentColor.withValues(alpha: 0.5),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );

    if (accentColor == null) return content;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(color: accentColor.withValues(alpha: 0.28)),
      ),
      child: content,
    );
  }
}

class _ActivityLogSection extends StatelessWidget {
  const _ActivityLogSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDetailsCubit, DeviceDetailsState>(
      builder: (context, state) {
        return _Section(
          title: 'سجل النشاط',
          child: Column(
            children: [
              for (final entry in state.activityLog)
                _ActivityLogTile(entry: entry),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityLogTile extends StatelessWidget {
  final ActivityLogEntry entry;

  const _ActivityLogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: entry.highlighted
                      ? colorScheme.secondary
                      : colorScheme.outline,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
              ),
              Expanded(
                child: Container(width: 1, color: colorScheme.outlineVariant),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(entry.title, style: AppTextStyles.labelStrong),
                  const SizedBox(height: AppSpacing.xs),
                  Text(entry.description, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDateTime(entry.createdAt),
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

class _IndustrialCard extends StatelessWidget {
  final Widget child;

  const _IndustrialCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.labelStrong.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _LargeTextField extends StatefulWidget {
  final String label;
  final String initialValue;
  final bool accent;
  final ValueChanged<String> onChanged;

  const _LargeTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.accent = false,
  });

  @override
  State<_LargeTextField> createState() => _LargeTextFieldState();
}

class _LargeTextFieldState extends State<_LargeTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          right: widget.accent
              ? BorderSide(color: colorScheme.secondary, width: 4)
              : BorderSide(color: colorScheme.outlineVariant),
          top: BorderSide(color: colorScheme.outlineVariant),
          left: BorderSide(color: colorScheme.outlineVariant),
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: AppTextStyles.labelStrong.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            maxLines: 4,
            onChanged: widget.onChanged,
            style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatMoney(double value) => '${value.toStringAsFixed(2)} ريال يمني';

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${_formatDate(date)}  $hour:$minute';
}

class SparePartPickerDialog extends StatefulWidget {
  const SparePartPickerDialog({super.key});

  @override
  State<SparePartPickerDialog> createState() => _SparePartPickerDialogState();
}

class _SparePartPickerDialogState extends State<SparePartPickerDialog> {
  final TextEditingController searchController = TextEditingController();

  String query = '';
  Compound? selectedSparePart;

  void filterSpareParts(String value) {
    setState(() {
      query = value;
      selectedSparePart = null;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Header
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "اختيار قطعة",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Search
            TextField(
              controller: searchController,
              onChanged: filterSpareParts,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "ابحث عن قطعة...",
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorScheme.secondary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<CompoundsCubit, CompoundsState>(
                builder: (context, state) {
                  if (state is CompoundsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CompoundsError) {
                    return _SparePartPickerError(message: state.message);
                  }

                  final compounds = state is CompoundsLoaded
                      ? state.compounds
                      : <Compound>[];
                  final normalizedQuery = query.trim().toLowerCase();
                  final filteredSpareParts = normalizedQuery.isEmpty
                      ? compounds
                      : compounds
                            .where(
                              (item) =>
                                  item.name.toLowerCase().contains(
                                    normalizedQuery,
                                  ) ||
                                  (item.description ?? '')
                                      .toLowerCase()
                                      .contains(normalizedQuery),
                            )
                            .toList();

                  if (filteredSpareParts.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد قطع',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredSpareParts.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: colorScheme.outlineVariant),
                    itemBuilder: (context, index) {
                      final item = filteredSpareParts[index];
                      final isSelected = selectedSparePart?.id == item.id;

                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            selectedSparePart = item;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.secondary.withValues(alpha: 0.12)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.secondary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings,
                                size: 20,
                                color: isSelected
                                    ? colorScheme.secondary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name.isEmpty
                                          ? 'بدون اسم'
                                          : item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    if (item.description?.isNotEmpty ==
                                        true) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatMoney(item.sellPrice),
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: colorScheme.secondary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    child: const Text("إلغاء"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedSparePart == null
                        ? null
                        : () {
                            Navigator.pop(context, selectedSparePart);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                    ),
                    child: const Text("إضافة"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SparePartPickerError extends StatelessWidget {
  final String message;

  const _SparePartPickerError({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => context.read<CompoundsCubit>().fetch(size: 100),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
