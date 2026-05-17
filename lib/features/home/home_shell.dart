import 'package:engineering_ops_dashboard/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localization/l10n.dart';
import '../compounds/presentation/pages/compounds_page.dart';
import '../devices/presentation/pages/devices_page.dart';
import '../incomes/presentation/pages/incomes_page.dart';
import '../invoices/presentation/pages/invoice_page.dart';
import 'app_drawer.dart';
import 'state/home_cubit.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static void openDrawer(BuildContext context) {
    context
        .findAncestorStateOfType<_HomeShellState>()
        ?.scaffoldKey
        .currentState
        ?.openDrawer();
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <_NavItem>[
      _NavItem(label: l10n.dashboard, icon: Icons.dashboard_outlined),
      //   _NavItem(label: l10n.income, icon: Icons.payments_outlined),
      _NavItem(label: "الاجهزة", icon: Icons.inventory_2_outlined),
      _NavItem(label: "الفواتير", icon: Icons.receipt_long_outlined),
      _NavItem(label: "القطع", icon: Icons.engineering_outlined),
      //      _NavItem(label: l10n.admin, icon: Icons.settings_outlined),
    ];

    return BlocProvider(
      create: (_) => HomeCubit(),
      child: BlocBuilder<HomeCubit, int>(
        builder: (context, index) {
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            key: scaffoldKey,
            drawer: const AppDrawer(),
            body: IndexedStack(
              index: index,
              children: [
                DashboardScreen(),
                // _ComingSoon(title: l10n.dashboard),
                //    const IncomesPage(),
                const DevicesPage(),
                const InvoiceIndexPage(),
                const CompoundsPage(),
                //    const AdminScreen(),
              ],
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (i) {
                    final selected = i == index;
                    final item = items[i];
                    return Expanded(
                      child: _BottomNavButton(
                        label: item.label,
                        icon: item.icon,
                        selected: selected,
                        onTap: () => context.read<HomeCubit>().setIndex(i),
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

class _ComingSoon extends StatelessWidget {
  final String title;
  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.construction_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
