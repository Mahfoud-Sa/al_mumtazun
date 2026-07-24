import 'package:engineering_ops_dashboard/core/services/platform_service.dart';
import 'package:engineering_ops_dashboard/features/dashboard/dashboard_screen.dart';
import 'package:engineering_ops_dashboard/features/home/desktop_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/app_header.dart';
import '../../localization/l10n.dart';
import '../compounds/presentation/pages/compounds_page.dart';
import '../devices/presentation/pages/devices_page.dart';
import '../diagnostics/presentation/pages/diagnostics_page.dart';
import '../invoices/presentation/pages/invoice_page.dart';
import '../profile/presentation/pages/profile_page.dart';
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

    return BlocProvider(
      create: (_) => HomeCubit(),
      child: BlocBuilder<HomeCubit, int>(
        builder: (context, index) {
          final colorScheme = Theme.of(context).colorScheme;

          if (PlatformService.isDesktop) {
            final desktopPages = const <Widget>[
              DashboardScreen(),
              DevicesPage(),
              InvoiceIndexPage(),
              CompoundsPage(),
              DiagnosticsPage(),
            ];

            final desktopNavItems = <DesktopNavItem>[
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
              DesktopNavItem(
                label: 'المشكلات والتشخيص',
                icon: Icons.bug_report_sharp,
                selectedIcon: Icons.bug_report_rounded,
                description:
                    'إدارة أعطال الأجهزة وتشخيصاتها والإجراءات الفنية المتخذة.',
              ),
            ];

            final safeDesktopIndex = index.clamp(0, desktopPages.length - 1);

            return Scaffold(
              body: Row(
                children: [
                  DesktopSidebar(
                    selectedIndex: safeDesktopIndex,
                    onItemSelected: (selectedIndex) {
                      context.read<HomeCubit>().setIndex(selectedIndex);
                    },
                    items: desktopNavItems,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        AppHeader(
                          title: desktopNavItems[safeDesktopIndex].label,
                          tapIcon: desktopNavItems[safeDesktopIndex].icon,
                          username: 'المهندس',
                          userInitial: 'م',
                          showDrawerButton: false,
                          showSearch: true,
                          showDesktopMenus: true,
                          onDrawerPressed: () => AppShell.openDrawer(context),
                          onProfilePressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: safeDesktopIndex,
                            children: desktopPages,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Mobile Layout
          final mobilePages = const <Widget>[
            DashboardScreen(),
            DevicesPage(),
            InvoiceIndexPage(),
            CompoundsPage(),
          ];

          final mobileNavItems = <_NavItem>[
            _NavItem(label: l10n.dashboard, icon: Icons.dashboard_outlined),
            const _NavItem(label: 'الأجهزة', icon: Icons.inventory_2_outlined),
            const _NavItem(label: 'الفواتير', icon: Icons.receipt_long_outlined),
            _NavItem(label: l10n.components, icon: Icons.engineering_outlined),
          ];

          final safeMobileIndex = index.clamp(0, mobilePages.length - 1);

          return Scaffold(
            key: scaffoldKey,
            drawer: const AppDrawer(),
            body: IndexedStack(
              index: safeMobileIndex,
              children: mobilePages,
            ),
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
                  children: List.generate(mobileNavItems.length, (i) {
                    return Expanded(
                      child: _BottomNavButton(
                        label: mobileNavItems[i].label,
                        icon: mobileNavItems[i].icon,
                        selected: i == safeMobileIndex,
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
