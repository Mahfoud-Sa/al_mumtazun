import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../../theme/app_colors.dart';
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isEditing ? 'تعديل فاتورة' : 'إضافة فاتورة'),
          leading: IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back),
          ),
          shape: const Border(
            bottom: BorderSide(color: AppColors.outlineVariant),
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
                  backgroundColor: AppColors.error,
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
                                    child: const Text('إلغاء'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isSaving ? null : _submit,
                                    icon: isSaving
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
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
    final selected = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أضف مكونا واحدا على الأقل قبل حفظ الفاتورة'),
          backgroundColor: AppColors.error,
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
      SnackBar(
        content: Text(
          _isEditing ? 'تم تحديث الفاتورة بنجاح' : 'تم حفظ الفاتورة بنجاح',
        ),
        backgroundColor: AppColors.success,
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
    return _IndustrialCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('بيانات الفاتورة', style: AppTextStyles.sectionHeading),
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
                    decoration: const InputDecoration(
                      labelText: 'رقم الجهاز',
                      prefixIcon: Icon(Icons.precision_manufacturing_outlined),
                    ),
                    validator: _positiveIntValidator,
                  ),
                TextFormField(
                  controller: customerIdController,
                  keyboardType: TextInputType.number,
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
              foregroundColor: AppColors.error,
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
    return _IndustrialCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'عناصر الفاتورة',
                  style: AppTextStyles.sectionHeading,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => onAdd(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة عنصر'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  color: AppColors.surfaceContainerHigh,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'القطع المراد تبديلها / إصلاحها',
                          style: AppTextStyles.labelStrong,
                        ),
                      ),
                      Text('السعر', style: AppTextStyles.labelStrong),
                    ],
                  ),
                ),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.onSurfaceVariant,
                          size: 36,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'لا توجد مكونات في الفاتورة',
                          style: AppTextStyles.body,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isEmpty ? 'مكون بدون اسم' : item.name,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'رقم القطعة: ${item.sparePartId ?? 0} | سعر الوحدة: ${_formatMoney(item.unitPrice)}',
                  style: AppTextStyles.label,
                ),
              ],
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
            constraints: const BoxConstraints(minWidth: 42),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              '${item.quantity}x',
              textAlign: TextAlign.center,
              style: AppTextStyles.label,
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
          Text(_formatMoney(item.total), style: AppTextStyles.labelStrong),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'حذف المادة',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.error,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _InvoiceItemEditor extends StatelessWidget {
  final int index;
  final _InvoiceItemDraft item;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _InvoiceItemEditor({
    required this.index,
    required this.item,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'عنصر ${index + 1}',
                style: AppTextStyles.labelStrong,
              ),
            ),
            IconButton(
              tooltip: 'حذف العنصر',
              onPressed: canRemove ? onRemove : null,
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final fields = [
              TextFormField(
                controller: item.sparePartIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رقم قطعة الغيار',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: _nonNegativeIntValidator,
              ),
              TextFormField(
                controller: item.nameController,
                decoration: const InputDecoration(labelText: 'اسم العنصر'),
              ),
              TextFormField(
                controller: item.quantityController,
                keyboardType: TextInputType.number,
                onChanged: (_) => onChanged(),
                decoration: const InputDecoration(labelText: 'الكمية'),
                validator: _positiveIntValidator,
              ),
              TextFormField(
                controller: item.unitPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => onChanged(),
                decoration: const InputDecoration(labelText: 'سعر الوحدة'),
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
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            'الإجمالي: ${_formatMoney(item.total)}',
            style: AppTextStyles.labelStrong,
          ),
        ),
      ],
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
    return _IndustrialCard(
      child: Column(
        children: [
          _TotalRow(label: 'قبل الخصم', value: subtotal),
          const Divider(height: 24, color: AppColors.outlineVariant),
          _TotalRow(label: 'الخصم', value: discount),
          const Divider(height: 24, color: AppColors.outlineVariant),
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
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: strong ? AppTextStyles.labelStrong : AppTextStyles.body,
          ),
        ),
        Text(
          _formatMoney(value),
          style: strong
              ? AppTextStyles.sectionHeading
              : AppTextStyles.labelStrong,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
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
    return Dialog(
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
                  const Icon(Icons.inventory_2_outlined),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'اختيار مكون',
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
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _query = value.trim().toLowerCase();
                    _selected = null;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'ابحث عن مكون...',
                  prefixIcon: Icon(Icons.search),
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
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: AppColors.outlineVariant,
                      ),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final selected = _selected?.id == item.id;

                        return InkWell(
                          onTap: () => setState(() => _selected = item),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            color: selected
                                ? AppColors.secondaryContainer.withValues(
                                    alpha: 0.45,
                                  )
                                : Colors.white,
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.settings_outlined,
                                  color: selected
                                      ? AppColors.secondary
                                      : AppColors.onSurfaceVariant,
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
                                        style: AppTextStyles.labelStrong,
                                      ),
                                      if (item.description?.isNotEmpty ==
                                          true) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          item.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.label,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatMoney(item.sellPrice),
                                  style: AppTextStyles.labelStrong,
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
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selected == null
                          ? null
                          : () => Navigator.of(context).pop(_selected),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isError ? AppColors.error : AppColors.onSurfaceVariant,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body,
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
