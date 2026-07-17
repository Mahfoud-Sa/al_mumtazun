import 'package:engineering_ops_dashboard/core/services/platform_service.dart';
import 'package:engineering_ops_dashboard/features/dashboard/dashboard_screen.dart';
import 'package:engineering_ops_dashboard/features/home/desktop_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localization/l10n.dart';
import '../compounds/presentation/pages/compounds_page.dart';
import '../devices/presentation/pages/devices_page.dart';
import '../invoices/presentation/pages/invoice_page.dart';
import 'app_drawer.dart';
import 'state/home_cubit.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static void openDrawer(BuildContext context) {
    context
        .findAncestorStateOfType<_AppShellState>()
        ?.scaffoldKey
        .currentState
        ?.openDrawer();
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <_NavItem>[
      _NavItem(label: l10n.dashboard, icon: Icons.dashboard_outlined),
      //   _NavItem(label: l10n.income, icon: Icons.payments_outlined),
      const _NavItem(label: 'الأجهزة', icon: Icons.inventory_2_outlined),
      const _NavItem(label: 'الفواتير', icon: Icons.receipt_long_outlined),
      _NavItem(label: l10n.components, icon: Icons.engineering_outlined),
      //      _NavItem(label: l10n.admin, icon: Icons.settings_outlined),
    ];

    return BlocProvider(
      create: (_) => HomeCubit(),
      child: BlocBuilder<HomeCubit, int>(
        builder: (context, index) {
          final colorScheme = Theme.of(context).colorScheme;

          final content = IndexedStack(
            index: index,
            children: [
              DashboardScreen(),
              const DevicesPage(),
              const InvoiceIndexPage(),
              const CompoundsPage(),
            ],
          );

          if (PlatformService.isDesktop) {
            return Scaffold(
              body: Row(
                children: [
                  DesktopSidebar(
                    selectedIndex: index,
                    onItemSelected: (selectedIndex) {
                      context.read<HomeCubit>().setIndex(selectedIndex);
                    },
                    items: [
                      DesktopNavItem(
                        label: l10n.dashboard,
                        icon: Icons.dashboard_outlined,
                        selectedIcon: Icons.dashboard_rounded,
                        description: 'الملخص والاتجاهات',
                      ),
                      DesktopNavItem(
                        label: 'الأجهزة',
                        icon: Icons.inventory_2_outlined,
                        selectedIcon: Icons.inventory_2_rounded,
                        description: 'إدارة ومتابعة الأجهزة',
                      ),
                      DesktopNavItem(
                        label: l10n.invoices,
                        icon: Icons.receipt_long_outlined,
                        selectedIcon: Icons.receipt_long_rounded,
                        description: 'الفواتير والمستحقات',
                      ),
                      DesktopNavItem(
                        label: l10n.components,
                        icon: Icons.engineering_outlined,
                        selectedIcon: Icons.engineering_rounded,
                        description: 'المكونات والمخزون',
                      ),
                    ],
                  ),

                  Expanded(child: content),
                ],
              ),
            );
          }

          return Scaffold(
            key: scaffoldKey,

            drawer: const AppDrawer(),

            body: content,

            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),

                child: Row(
                  children: List.generate(items.length, (i) {
                    return Expanded(
                      child: _BottomNavButton(
                        label: items[i].label,
                        icon: items[i].icon,
                        selected: i == index,
                        onTap: () {
                          context.read<HomeCubit>().setIndex(i);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem({required this.label, required this.icon});
}

class _BottomNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge!;
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected
        ? colorScheme.secondary
        : colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colorScheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? colorScheme.onSurface : color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(
                color: selected ? colorScheme.onSurface : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
