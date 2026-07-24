import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/index_view_toggle.dart';
import '../../../../di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../../home/app_shell.dart';
import '../../domain/entities/diagnostic.dart';
import '../cubit/diagnostics_cubit.dart';
import '../cubit/diagnostics_state.dart';
import 'add_diagnostic_page.dart';
import 'diagnostic_details_page.dart';
import 'delete_diagnostic_dialog.dart';
import 'edit_diagnostic_dialog.dart';

String _formatDate(DateTime dt) {
  final y = dt.year;
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y/$m/$d';
}

class DiagnosticsPage extends StatelessWidget {
  const DiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DiagnosticsCubit>()..fetch(),
      child: const _DiagnosticsView(),
    );
  }
}

class _DiagnosticsView extends StatefulWidget {
  const _DiagnosticsView();

  @override
  State<_DiagnosticsView> createState() => _DiagnosticsViewState();
}

class _DiagnosticsViewState extends State<_DiagnosticsView> {
  final _scrollController = ScrollController();
  IndexViewMode _viewMode = IndexViewMode.list;

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
    if (_viewMode != IndexViewMode.grid) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 360) {
      context.read<DiagnosticsCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () => context.read<DiagnosticsCubit>().fetch(page: 1),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (Platform.isAndroid || Platform.isIOS) ...{
                  const _DiagnosticsHeader(),
                } else
                  ...{},

                const SizedBox(height: 24),
                const _DiagnosticsFilters(),
                const SizedBox(height: 16),
                IndexViewControls(
                  viewMode: _viewMode,
                  onViewModeChanged: (mode) {
                    setState(() => _viewMode = mode);
                    context.read<DiagnosticsCubit>().fetch(page: 1);
                  },
                ),
                const SizedBox(height: 24),
                _DiagnosticsBody(viewMode: _viewMode),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosticsHeader extends StatelessWidget {
  const _DiagnosticsHeader();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'القائمة',
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => AppShell.openDrawer(context),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'المشكلات والتشخيص',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'إدارة أعطال وتعديلات الأجهزة والتقارير الفنية المتخذة.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!isWide) const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            final cubit = context.read<DiagnosticsCubit>();
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const AddDiagnosticPage(),
                ),
              ),
            );
            if (created == true && context.mounted) {
              context.read<DiagnosticsCubit>().fetch(page: 1);
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('إضافة تشخيص جديد'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiagnosticsFilters extends StatefulWidget {
  const _DiagnosticsFilters();

  @override
  State<_DiagnosticsFilters> createState() => _DiagnosticsFiltersState();
}

class _DiagnosticsFiltersState extends State<_DiagnosticsFilters> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _sortBy = 'id';
  String _sortDirection = 'asc';
  String _severity = 'الكل';
  String _status = 'الكل';

  final List<String> _severityList = const ['الكل', 'منخفض', 'متوسط', 'عالي', 'حرج'];
  final List<String> _statusList = const ['الكل', 'قيد الانتظار', 'قيد المعالجة', 'تم الحل', 'مغلق'];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: isWide ? 3 : 1,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _queueApply,
                    decoration: InputDecoration(
                      hintText: 'البحث عن عنوان، كود، أعراض، أو اسم الفني...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _apply();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                if (isWide) const SizedBox(width: 16),
                if (isWide)
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<String>(
                      initialValue: '$_sortBy:$_sortDirection',
                      decoration: InputDecoration(
                        labelText: 'الترتيب حسب',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'id:asc', child: Text('الرقم التعريف تصاعدي')),
                        DropdownMenuItem(value: 'id:desc', child: Text('الرقم التعريف تنازلي')),
                        DropdownMenuItem(value: 'date:desc', child: Text('التاريخ الأحدث')),
                        DropdownMenuItem(value: 'date:asc', child: Text('التاريخ الأقدم')),
                        DropdownMenuItem(value: 'title:asc', child: Text('العنوان أبجدياً')),
                        DropdownMenuItem(value: 'severity:desc', child: Text('الخطورة الأكثر حرجاً')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          final parts = val.split(':');
                          setState(() {
                            _sortBy = parts[0];
                            _sortDirection = parts[1];
                          });
                          _apply();
                        }
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('مستوى الخطورة: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<String>(
                          value: _severity,
                          underline: const SizedBox(),
                          items: _severityList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _severity = val);
                              _apply();
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('الحالة: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<String>(
                          value: _status,
                          underline: const SizedBox(),
                          items: _statusList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _status = val);
                              _apply();
                            }
                          },
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _clear,
                      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                      label: const Text('إعادة ضبط الفلاتر'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _queueApply(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _apply);
  }

  void _apply() {
    context.read<DiagnosticsCubit>().applyQuery(
          search: _searchController.text,
          severity: _severity == 'الكل' ? null : _severity,
          status: _status == 'الكل' ? null : _status,
          sortBy: _sortBy,
          sortDirection: _sortDirection,
        );
  }

  void _clear() {
    _searchController.clear();
    setState(() {
      _severity = 'الكل';
      _status = 'الكل';
      _sortBy = 'id';
      _sortDirection = 'asc';
    });
    context.read<DiagnosticsCubit>().clearQuery();
  }
}

class _DiagnosticsBody extends StatelessWidget {
  final IndexViewMode viewMode;

  const _DiagnosticsBody({required this.viewMode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiagnosticsCubit, DiagnosticsState>(
      builder: (context, state) {
        if (state is DiagnosticsLoading) {
          return const Padding(
            padding: EdgeInsets.all(48.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DiagnosticsError) {
          return Padding(
            padding: const EdgeInsets.all(48.0),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('خطأ: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DiagnosticsCubit>().fetch(page: 1),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DiagnosticsLoaded) {
          if (state.diagnostics.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد تشخيصات مطابقة للمحددات الحالية.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          if (viewMode == IndexViewMode.grid) {
            return Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    mainAxisExtent: 260,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.diagnostics.length,
                  itemBuilder: (context, index) {
                    final item = state.diagnostics[index];
                    return _DiagnosticCard(diagnostic: item);
                  },
                ),
                if (state.isLoadingMore) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ],
            );
          }

          // Table Mode
          return Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('الكود')),
                      DataColumn(label: Text('العنوان')),
                      DataColumn(label: Text('الخطورة')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('الفني')),
                      DataColumn(label: Text('تاريخ الإنشاء')),
                      DataColumn(label: Text('الإجراءات')),
                    ],
                    rows: state.diagnostics.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item.diagnosticCode, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (item.subtitle != null)
                                  Text(item.subtitle!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          DataCell(_SeverityTextBadge(severity: item.severity)),
                          DataCell(_StatusTextBadge(status: item.status)),
                          DataCell(Text(item.technicianName ?? '-')),
                          DataCell(Text(_formatDate(item.createdAt))),
                          DataCell(
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (val) => _handleAction(context, val, item),
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'view', child: Text('عرض التفاصيل')),
                                PopupMenuItem(value: 'edit', child: Text('تعديل')),
                                PopupMenuItem(value: 'delete', child: Text('حذف')),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Pagination Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي النتائج: ${state.totalCount}'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: state.page > 1
                            ? () => context.read<DiagnosticsCubit>().previousPage()
                            : null,
                      ),
                      Text('صفحة ${state.page} من ${state.totalPages}'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: state.page < state.totalPages
                            ? () => context.read<DiagnosticsCubit>().nextPage()
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _handleAction(BuildContext context, String action, Diagnostic item) async {
    final cubit = context.read<DiagnosticsCubit>();
    if (action == 'view') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: DiagnosticDetailsPage(diagnostic: item),
          ),
        ),
      );
    } else if (action == 'edit') {
      final updated = await showDialog<Diagnostic>(
        context: context,
        builder: (_) => EditDiagnosticDialog(diagnostic: item),
      );
      if (updated != null && context.mounted) {
        cubit.editDiagnostic(updated);
      }
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => DeleteDiagnosticDialog(diagnostic: item),
      );
      if (confirm == true && context.mounted) {
        cubit.removeDiagnostic(item.id);
      }
    }
  }
}

class _DiagnosticCard extends StatelessWidget {
  final Diagnostic diagnostic;

  const _DiagnosticCard({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      diagnostic.diagnosticCode,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (val) {
                        final cubit = context.read<DiagnosticsCubit>();
                        if (val == 'view') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: DiagnosticDetailsPage(diagnostic: diagnostic),
                              ),
                            ),
                          );
                        } else if (val == 'edit') {
                          showDialog<Diagnostic>(
                            context: context,
                            builder: (_) => EditDiagnosticDialog(diagnostic: diagnostic),
                          ).then((updated) {
                            if (updated != null) cubit.editDiagnostic(updated);
                          });
                        } else if (val == 'delete') {
                          showDialog<bool>(
                            context: context,
                            builder: (_) => DeleteDiagnosticDialog(diagnostic: diagnostic),
                          ).then((confirm) {
                            if (confirm == true) cubit.removeDiagnostic(diagnostic.id);
                          });
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'view', child: Text('عرض التفاصيل')),
                        PopupMenuItem(value: 'edit', child: Text('تعديل')),
                        PopupMenuItem(value: 'delete', child: Text('حذف')),
                      ],
                    ),
                  ],
                ),
                Text(
                  diagnostic.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (diagnostic.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    diagnostic.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  diagnostic.description ?? diagnostic.symptoms ?? 'لا يوجد وصف تفصيلي.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SeverityTextBadge(severity: diagnostic.severity),
                    _StatusTextBadge(status: diagnostic.status),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      diagnostic.technicianName != null ? 'الفني: ${diagnostic.technicianName}' : '',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      _formatDate(diagnostic.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeverityTextBadge extends StatelessWidget {
  final String severity;

  const _SeverityTextBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (severity) {
      case 'حرج':
        color = Colors.red;
        break;
      case 'عالي':
        color = Colors.orange;
        break;
      case 'متوسط':
        color = Colors.amber.shade800;
        break;
      default:
        color = Colors.blue;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        severity,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _StatusTextBadge extends StatelessWidget {
  final String status;

  const _StatusTextBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'تم الحل':
        color = Colors.green;
        break;
      case 'مغلق':
        color = Colors.grey;
        break;
      case 'قيد المعالجة':
        color = Colors.blue;
        break;
      default:
        color = Colors.purple;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
