import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localization/l10n.dart';
import '../../theme/app_colors.dart';
import '../dashboard/dashboard_screen.dart';
import '../income/income_screen.dart';
import '../inventory/inventory_screen.dart';
import '../engineering/engineering_screen.dart';
import '../admin/admin_screen.dart';
import 'app_drawer.dart';
import 'state/home_cubit.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static void openDrawer(BuildContext context) {
    context.findAncestorStateOfType<_HomeShellState>()?.scaffoldKey.currentState?.openDrawer();
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
      _NavItem(label: l10n.income, icon: Icons.payments_outlined),
      _NavItem(label: l10n.inventory, icon: Icons.inventory_2_outlined),
      _NavItem(label: l10n.engineering, icon: Icons.engineering_outlined),
      _NavItem(label: l10n.admin, icon: Icons.settings_outlined),
    ];

    return BlocProvider(
      create: (_) => HomeCubit(),
      child: BlocBuilder<HomeCubit, int>(
        builder: (context, index) {
          return Scaffold(
            key: scaffoldKey,
            drawer: const AppDrawer(),
            body: IndexedStack(
              index: index,
              children: const [
                DashboardScreen(),
                IncomeScreen(),
                InventoryScreen(),
                EngineeringScreen(),
                AdminScreen(),
              ],
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.outlineVariant)),
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
    final color = selected ? AppColors.secondary : AppColors.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? AppColors.onSurface : color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(
                color: selected ? AppColors.onSurface : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final _PlaceholderKey titleKey;
  const _PlaceholderPage({required this.titleKey});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (titleKey) {
      _PlaceholderKey.income => l10n.income,
      _PlaceholderKey.inventory => l10n.inventory,
      _PlaceholderKey.engineering => l10n.engineering,
      _PlaceholderKey.admin => l10n.admin,
    };

    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

enum _PlaceholderKey { income, inventory, engineering, admin }

