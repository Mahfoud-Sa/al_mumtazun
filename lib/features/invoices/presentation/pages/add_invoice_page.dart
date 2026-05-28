import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../compounds/domain/entities/compound.dart';
import '../../../compounds/presentation/cubit/compounds_cubit.dart';
import '../../../compounds/presentation/cubit/compounds_state.dart';
import '../../../devices/domain/entities/device.dart';
import '../../../devices/domain/usecases/get_devices_usecase.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../cubit/invoices_cubit.dart';
import '../cubit/invoices_state.dart';

class AddInvoicePage extends StatefulWidget {
  final Invoice? invoice;

  const AddInvoicePage({super.key, this.invoice});

  @override
  State<AddInvoicePage> createState() => _AddInvoicePageState();
}

class _AddInvoicePageState extends State<AddInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final List<_InvoiceItemDraft> _items = [];

  DateTime _invoiceDate = DateTime.now();
  late Future<List<Device>> _devicesFuture;
  String? _selectedDeviceId;

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    if (invoice != null) {
      _invoiceDate = invoice.date;
      if (invoice.deviceId > 0) {
        _selectedDeviceId = invoice.deviceId.toString();
        _deviceIdController.text = _selectedDeviceId!;
      }
      _customerIdController.text = invoice.customerId.toString();
      _discountController.text = invoice.discount.toStringAsFixed(2);
      _items.addAll(invoice.items.map(_InvoiceItemDraft.fromInvoiceItem));
    }
    _devicesFuture = _loadDevices();
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _customerIdController.dispose();
    _discountController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.invoice != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(isEditing ? 'تعديل فاتورة' : 'إضافة فاتورة'),
          leading: IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back),
          ),
          shape: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        body: SafeArea(
          child: BlocListener<InvoicesCubit, InvoicesState>(
            listenWhen: (previous, current) =>
                previous.createErrorMessage != current.createErrorMessage ||
                previous.updateErrorMessage != current.updateErrorMessage,
            listener: (context, state) {
              final message =
                  state.createErrorMessage ?? state.updateErrorMessage;
              if (message == null) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: colorScheme.error,
                ),
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _InvoiceDetailsCard(
                          deviceIdController: _deviceIdController,
                          customerIdController: _customerIdController,
                          discountController: _discountController,
                          invoiceDate: _invoiceDate,
                          devicesFuture: _devicesFuture,
                          selectedDeviceId: _selectedDeviceId,
                          onDeviceChanged: _selectDevice,
                          onReloadDevices: _reloadDevices,
                          onPickDate: _pickDate,
                          onTotalsChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _ItemsCard(
                          items: _items,
                          onChanged: () => setState(() {}),
                          onAdd: _pickAndAddItem,
                          onRemove: _removeItem,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _TotalsCard(
                          subtotal: _subtotal,
                          discount: _discount,
                          total: _total,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        BlocBuilder<InvoicesCubit, InvoicesState>(
                          builder: (context, state) {
                            final isSaving =
                                state.isCreatingInvoice ||
                                state.isUpdatingInvoice;
                            return Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isSaving
                                        ? null
                                        : () =>
                                              Navigator.of(context).pop(false),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.onSurfaceVariant,
                                      side: BorderSide(color: colorScheme.outline),
                                    ),
                                    child: const Text('إلغاء'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isSaving ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.secondary,
                                      foregroundColor: colorScheme.onSecondary,
                                    ),
                                    icon: isSaving
                                        ? SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colorScheme.onSecondary,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.receipt_long_outlined,
                                            size: 18,
                                          ),
                                    label: Text(
                                      isEditing
                                          ? 'تحديث الفاتورة'
                                          : 'حفظ الفاتورة',
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  double get _discount => double.tryParse(_discountController.text.trim()) ?? 0;

  double get _total {
    final value = _subtotal - _discount;
    return value < 0 ? 0 : value;
  }

  bool get _isEditing => widget.invoice != null;

  Future<List<Device>> _loadDevices() async {
    final result = await getIt<GetDevicesUseCase>()(
      const GetDevicesParams(page: 1, size: 100),
    );

    return result.fold((failure) => throw Exception(failure.message), (
      devicePage,
    ) {
      return devicePage.devices;
    });
  }

  void _reloadDevices() {
    setState(() {
      _devicesFuture = _loadDevices();
    });
  }

  void _selectDevice(String? id) {
    setState(() {
      _selectedDeviceId = id?.trim().isEmpty ?? true ? null : id;
      _deviceIdController.text = _selectedDeviceId ?? '';
    });
  }

  Future<void> _pickDate() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selected = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: colorScheme.secondary,
                    onPrimary: colorScheme.onSecondary,
                    surface: colorScheme.surface,
                    onSurface: colorScheme.onSurface,
                  )
                : ColorScheme.light(
                    primary: colorScheme.secondary,
                    onPrimary: colorScheme.onSecondary,
                    surface: colorScheme.surface,
                    onSurface: colorScheme.primary,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null || !mounted) return;
    setState(() {
      _invoiceDate = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _invoiceDate.hour,
        _invoiceDate.minute,
      );
    });
  }

  Future<void> _pickAndAddItem() async {
    final result = await showDialog<Compound>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => getIt<CompoundsCubit>()..fetch(size: 100),
        child: const _SparePartPickerDialog(),
      ),
    );

    if (result == null || !mounted) return;

    final existingIndex = _items.indexWhere(
      (item) =>
          item.sparePartId == result.id && item.unitPrice == result.sellPrice,
    );

    setState(() {
      if (existingIndex == -1) {
        _items.add(_InvoiceItemDraft.fromCompound(result));
        return;
      }

      _items[existingIndex].quantityController.text =
          (_items[existingIndex].quantity + 1).toString();
    });
  }

  void _removeItem(int index) {
    final removed = _items.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _submit() async {
    final colorScheme = Theme.of(context).colorScheme;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('أضف مكونا واحدا على الأقل قبل حفظ الفاتورة'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    final deviceId = int.tryParse(_deviceIdController.text.trim()) ?? 0;
    final customerId = int.parse(_customerIdController.text.trim());
    final items = _items
        .map(
          (item) => InvoiceItem(
            id: 0,
            invoiceId: 0,
            sparePartId: item.sparePartId,
            sparePartName: item.name,
            visualIndex: 0,
            quantity: int.parse(item.quantityController.text.trim()),
            unitPrice: item.unitPrice,
          ),
        )
        .toList();

    final invoice = Invoice(
      id: widget.invoice?.id ?? 0,
      deviceId: deviceId,
      device: null,
      customerId: customerId,
      date: _invoiceDate,
      discount: _discount < 0 ? 0 : _discount,
      items: items,
    );

    final cubit = context.read<InvoicesCubit>();
    final saved = _isEditing
        ? await cubit.updateExistingInvoice(
            id: widget.invoice!.id,
            invoice: invoice,
          )
        : await cubit.addInvoice(invoice);
    if (!mounted || !saved) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الفاتورة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(true);
  }
}

class _InvoiceDetailsCard extends StatelessWidget {
  final TextEditingController deviceIdController;
  final TextEditingController customerIdController;
  final TextEditingController discountController;
  final DateTime invoiceDate;
  final Future<List<Device>> devicesFuture;
  final String? selectedDeviceId;
  final ValueChanged<String?> onDeviceChanged;
  final VoidCallback onReloadDevices;
  final VoidCallback onPickDate;
  final VoidCallback onTotalsChanged;

  const _InvoiceDetailsCard({
    required this.deviceIdController,
    required this.customerIdController,
    required this.discountController,
    required this.invoiceDate,
    required this.devicesFuture,
    required this.selectedDeviceId,
    required this.onDeviceChanged,
    required this.onReloadDevices,
    required this.onPickDate,
    required this.onTotalsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _IndustrialCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بيانات الفاتورة',
            style: AppTextStyles.sectionHeading.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final fields = [
                _DeviceDropdownField(
                  devicesFuture: devicesFuture,
                  selectedDeviceId: selectedDeviceId,
                  onChanged: onDeviceChanged,
                  onRetry: onReloadDevices,
                ),
                if (deviceIdController.text == '__manual__')
                  TextFormField(
                    controller: deviceIdController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'رقم الجهاز',
                      prefixIcon: Icon(Icons.precision_manufacturing_outlined),
                    ),
                    validator: _positiveIntValidator,
                  ),
                TextFormField(
                  controller: customerIdController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'رقم العميل',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _nonNegativeIntValidator,
                ),
                TextFormField(
                  controller: discountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => onTotalsChanged(),
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'الخصم',
                    prefixIcon: Icon(Icons.discount_outlined),
                  ),
                  validator: _nonNegativeMoneyValidator,
                ),
              ];

              if (!isWide) {
                return Column(
                  children: [
                    for (var i = 0; i < fields.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.md),
                      fields[i],
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < fields.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(child: fields[i]),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(_formatDate(invoiceDate)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerRight,
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(color: colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceDropdownField extends StatelessWidget {
  final Future<List<Device>> devicesFuture;
  final String? selectedDeviceId;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRetry;

  const _DeviceDropdownField({
    required this.devicesFuture,
    required this.selectedDeviceId,
    required this.onChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<Device>>(
      future: devicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const InputDecorator(
            decoration: InputDecoration(
              labelText: 'الجهاز',
              prefixIcon: Icon(Icons.precision_manufacturing_outlined),
            ),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: AppSpacing.sm),
                Text('جاري تحميل الأجهزة...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('تعذر تحميل الأجهزة، إعادة المحاولة'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerRight,
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
            ),
          );
        }

        final devices = snapshot.data ?? const <Device>[];
        final selectedExists =
            selectedDeviceId != null &&
            devices.any((device) => device.id == selectedDeviceId);

        return DropdownButtonFormField<String>(
          key: ValueKey('device-${selectedExists ? selectedDeviceId : 'none'}'),
          initialValue: selectedExists ? selectedDeviceId : '',
          isExpanded: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: const InputDecoration(
            labelText: 'الجهاز',
            prefixIcon: Icon(Icons.precision_manufacturing_outlined),
          ),
          items: [
            const DropdownMenuItem<String>(value: '', child: Text('بدون جهاز')),
            for (final device in devices)
              DropdownMenuItem<String>(
                value: device.id,
                child: Text(
                  _deviceLabel(device),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final List<_InvoiceItemDraft> items;
  final VoidCallback onChanged;
  final Future<void> Function() onAdd;
  final ValueChanged<int> onRemove;

  const _ItemsCard({
    required this.items,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _IndustrialCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'عناصر الفاتورة',
                  style: AppTextStyles.sectionHeading.copyWith(color: colorScheme.onSurface),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => onAdd(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة عنصر'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.outline),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
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
                          'القطع المراد تبديلها / إصلاحها',
                          style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
                        ),
                      ),
                      Text(
                        'السعر',
                        style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 36,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'لا توجد مكونات في الفاتورة',
                          style: AppTextStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                else
                  for (var i = 0; i < items.length; i++)
                    _InvoiceItemRow(
                      item: items[i],
                      onQuantityChanged: (quantity) {
                        if (quantity <= 0) {
                          onRemove(i);
                          return;
                        }
                        items[i].quantityController.text = quantity.toString();
                        onChanged();
                      },
                      onRemove: () => onRemove(i),
                    ),
                TextButton.icon(
                  onPressed: () => onAdd(),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('إضافة مكون'),
                  style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceItemRow extends StatelessWidget {
  final _InvoiceItemDraft item;
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
        color: colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isEmpty ? 'مكون بدون اسم' : item.name,
                  style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'رقم القطعة: ${item.sparePartId ?? 0} | سعر الوحدة: ${_formatMoney(item.unitPrice)}',
                  style: AppTextStyles.label.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'تقليل الكمية',
            onPressed: () => onQuantityChanged(item.quantity - 1),
            icon: const Icon(Icons.remove_circle_outline, size: 18),
            visualDensity: VisualDensity.compact,
            color: colorScheme.onSurface,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 42),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
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
            color: colorScheme.onSurface,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _formatMoney(item.total),
            style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'حذف المادة',
            onPressed: onRemove,
            icon: const Icon(Icons.visual_search_rounded, size: 18),
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

class _TotalsCard extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;

  const _TotalsCard({
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _IndustrialCard(
      child: Column(
        children: [
          _TotalRow(label: 'قبل الخصم', value: subtotal),
          Divider(height: 24, color: colorScheme.outlineVariant),
          _TotalRow(label: 'الخصم', value: discount),
          Divider(height: 24, color: colorScheme.outlineVariant),
          _TotalRow(label: 'الإجمالي', value: total, strong: true),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool strong;

  const _TotalRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: strong
                ? AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface)
                : AppTextStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          _formatMoney(value),
          style: strong
              ? AppTextStyles.sectionHeading.copyWith(color: colorScheme.secondary)
              : AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
        ),
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
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: child,
    );
  }
}

class _InvoiceItemDraft {
  final sparePartIdController = TextEditingController(text: '0');
  final nameController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final unitPriceController = TextEditingController(text: '0');

  _InvoiceItemDraft();

  factory _InvoiceItemDraft.fromCompound(Compound compound) {
    return _InvoiceItemDraft()
      ..sparePartIdController.text = compound.id.toString()
      ..nameController.text = compound.name
      ..unitPriceController.text = compound.sellPrice.toStringAsFixed(2);
  }

  factory _InvoiceItemDraft.fromInvoiceItem(InvoiceItem item) {
    return _InvoiceItemDraft()
      ..sparePartIdController.text = (item.sparePartId ?? 0).toString()
      ..nameController.text = item.sparePartName
      ..quantityController.text = item.quantity.toString()
      ..unitPriceController.text = item.unitPrice.toStringAsFixed(2);
  }

  int? get sparePartId => int.tryParse(sparePartIdController.text.trim());

  String get name => nameController.text.trim();

  int get quantity => int.tryParse(quantityController.text.trim()) ?? 0;

  double get unitPrice => double.tryParse(unitPriceController.text.trim()) ?? 0;

  double get total {
    return quantity * unitPrice;
  }

  void dispose() {
    sparePartIdController.dispose();
    nameController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}

class _SparePartPickerDialog extends StatefulWidget {
  const _SparePartPickerDialog();

  @override
  State<_SparePartPickerDialog> createState() => _SparePartPickerDialogState();
}

class _SparePartPickerDialogState extends State<_SparePartPickerDialog> {
  final _searchController = TextEditingController();
  String _query = '';
  Compound? _selected;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'اختيار مكون',
                      style: AppTextStyles.sectionHeading.copyWith(color: colorScheme.onSurface),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _query = value.trim().toLowerCase();
                    _selected = null;
                  });
                },
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مكون...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
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
                    borderSide: BorderSide(color: colorScheme.secondary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: BlocBuilder<CompoundsCubit, CompoundsState>(
                  builder: (context, state) {
                    if (state is CompoundsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CompoundsError) {
                      return _PickerMessage(
                        icon: Icons.error_outline,
                        message: state.message,
                        isError: true,
                      );
                    }

                    final compounds = state is CompoundsLoaded
                        ? state.compounds
                        : <Compound>[];
                    final filtered = _query.isEmpty
                        ? compounds
                        : compounds
                              .where(
                                (item) =>
                                    item.name.toLowerCase().contains(_query) ||
                                    (item.description ?? '')
                                        .toLowerCase()
                                        .contains(_query),
                              )
                              .toList();

                    if (filtered.isEmpty) {
                      return const _PickerMessage(
                        icon: Icons.inventory_2_outlined,
                        message: 'لا توجد مكونات',
                      );
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final selected = _selected?.id == item.id;

                        return InkWell(
                          onTap: () => setState(() => _selected = item),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            color: selected
                                ? colorScheme.secondary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.settings_outlined,
                                  color: selected
                                      ? colorScheme.secondary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name.isEmpty
                                            ? 'مكون بدون اسم'
                                            : item.name,
                                        style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
                                      ),
                                      if (item.description?.isNotEmpty ==
                                          true) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          item.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.label.copyWith(color: colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatMoney(item.sellPrice),
                                  style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
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
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(color: colorScheme.outline),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selected == null
                          ? null
                          : () => Navigator.of(context).pop(_selected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                      ),
                      child: const Text('إضافة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isError;

  const _PickerMessage({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isError ? colorScheme.error : colorScheme.onSurfaceVariant,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String? _positiveIntValidator(String? value) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed <= 0) return 'أدخل رقم أكبر من صفر';
  return null;
}

String? _nonNegativeIntValidator(String? value) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed < 0) return 'أدخل رقم صحيح';
  return null;
}

String? _nonNegativeMoneyValidator(String? value) {
  final parsed = double.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed < 0) return 'أدخل مبلغ صحيح';
  return null;
}

String _formatMoney(double value) => value.toStringAsFixed(2);

String _deviceLabel(Device device) {
  final name = device.name.trim().isEmpty ? 'جهاز بدون اسم' : device.name;
  final customer = device.customerName.trim();
  final suffix = customer.isEmpty ? '' : ' - $customer';
  return '#${device.id} | $name$suffix';
}

String _formatDate(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}  $hour:$minute';
}
