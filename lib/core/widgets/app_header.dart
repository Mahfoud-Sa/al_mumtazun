import 'package:engineering_ops_dashboard/core/widgets/desktop_profile_card.dart';
import 'package:engineering_ops_dashboard/features/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/tools/ohms_law_calculator.dart';
import '../../features/tools/power_calculator.dart';
import '../../features/tools/resistor_color_decoder.dart';
import '../../features/tools/tools_page.dart';
import '../../features/tools/voltage_divider_calculator.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showDrawerButton;
  final bool showSearch;
  final bool showDesktopMenus;
  final String username;
  final String userInitial;
  final VoidCallback? onDrawerPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLogout;
  final List<HeaderMenuItemData> menuItems;
  final int? selectedMenuIndex;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHintText;
  final bool showLogoutButton;
  final bool confirmLogout;
  final IconData tapIcon;
  final String? logoutTooltip;

  const AppHeader({
    super.key,
    required this.title,
    required this.username,
    required this.userInitial,
    required this.tapIcon,
    this.showDrawerButton = false,
    this.showSearch = true,
    this.showDesktopMenus = true,
    this.onDrawerPressed,
    this.onProfilePressed,
    this.onLogout,
    this.menuItems = const [],
    this.selectedMenuIndex,
    this.searchController,
    this.onSearchChanged,
    this.searchHintText = 'البحث داخل النظام...',
    this.showLogoutButton = true,
    this.confirmLogout = true,
    this.logoutTooltip = 'تسجيل الخروج',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: 64,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final showMenus = showDesktopMenus && width >= 960;
            final showSearchField = showSearch && width >= 760;
            final showLogout = showLogoutButton && width >= 430;

            return Row(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (showDrawerButton) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: onDrawerPressed,
                      icon: Icon(
                        Icons.menu_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else
                  const SizedBox(width: 2),
                Expanded(
                  child: Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  tapIcon,
                                  size: 18,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showMenus) ...[
                        const SizedBox(width: 14),
                        Expanded(
                          child: HeaderMenu(
                            items: menuItems.isNotEmpty
                                ? menuItems
                                : _buildDefaultMenuItems(context),
                            selectedIndex: selectedMenuIndex,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: showSearchField
                      ? SizedBox(
                          key: const ValueKey('search-visible'),
                          width: width >= 1100
                              ? 320
                              : width >= 900
                              ? 260
                              : 220,
                          child: HeaderSearch(
                            controller: searchController,
                            onChanged: onSearchChanged,
                            hintText: searchHintText ?? 'البحث داخل النظام...',
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('search-hidden')),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showLogout)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: LogoutButton(
                          onPressed: onLogout,
                          confirmBeforeLogout: confirmLogout,
                          tooltip: logoutTooltip ?? 'تسجيل الخروج',
                        ),
                      ),
                    SizedBox(
                      width: 180,
                      height: 48,
                      child: DesktopProfileCard(
                        name: "محمد سالم ",
                        role: "Admin",
                        onTap: () {
                          Navigator.of(context).pushNamed('/profile');
                        },
                      ),
                    ),
                    // UserProfileCard(
                    //   username: username,
                    //   userInitial: userInitial,
                    //   showUsername: showUsername,
                    //   onPressed: onProfilePressed,
                    // ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<HeaderMenuItemData> _buildDefaultMenuItems(BuildContext context) {
    return [
      HeaderMenuItemData(
        label: 'ملف',
        subItems: [
          HeaderSubMenuItemData(
            label: 'الملف الشخصي',
            icon: Icons.account_circle_outlined,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
        ],
      ),
      HeaderMenuItemData(
        label: 'تعديل',
        subItems: [
          // HeaderSubMenuItemData(
          //   label: 'حاسبة قانون أوم (Ohm\'s Law)',
          //   icon: Icons.flash_on_rounded,
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (_) => const OhmsLawCalculator()),
          //     );
          //   },
          // ),
          // HeaderSubMenuItemData(
          //   label: 'حساب القدرة الكهربائية (Power Calculator)',
          //   icon: Icons.bolt_rounded,
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (_) => const PowerCalculator()),
          //     );
          //   },
          // ),
          // HeaderSubMenuItemData(
          //   label: 'كود ألوان المقاومات (Resistor Decoder)',
          //   icon: Icons.palette_rounded,
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (_) => const ResistorColorDecoder()),
          //     );
          //   },
          // ),
          // HeaderSubMenuItemData(
          //   label: 'مقسم الجهد (Voltage Divider)',
          //   icon: Icons.alt_route_rounded,
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (_) => const VoltageDividerCalculator()),
          //     );
          //   },
          // ),
          // HeaderSubMenuItemData(
          //   label: 'جميع الأدوات الهندسية',
          //   icon: Icons.calculate_outlined,
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (_) => const EngineeringToolsPage()),
          //     );
          //   },
          // ),
        ],
      ),
      HeaderMenuItemData(
        label: 'الأدوات',
        subItems: [
          HeaderSubMenuItemData(
            label: 'لوحة الأدوات الهندسية',
            icon: Icons.design_services_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EngineeringToolsPage()),
              );
            },
          ),
          HeaderSubMenuItemData(
            label: 'حاسبة قانون أوم',
            icon: Icons.flash_on_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OhmsLawCalculator()),
              );
            },
          ),
          HeaderSubMenuItemData(
            label: 'حساب القدرة الكهربائية',
            icon: Icons.bolt_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PowerCalculator()),
              );
            },
          ),
          HeaderSubMenuItemData(
            label: 'شفرة ألوان المقاومات',
            icon: Icons.palette_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ResistorColorDecoder()),
              );
            },
          ),
          HeaderSubMenuItemData(
            label: 'مقسم / مجزئ الجهد',
            icon: Icons.alt_route_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VoltageDividerCalculator(),
                ),
              );
            },
          ),
        ],
      ),
      HeaderMenuItemData(label: 'عرض'),
      HeaderMenuItemData(label: 'مساعدة'),
    ];
  }
}

class HeaderMenu extends StatelessWidget {
  final List<HeaderMenuItemData> items;
  final int? selectedIndex;

  const HeaderMenu({super.key, required this.items, this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = selectedIndex != null && index == selectedIndex;

            return HeaderMenuItem(
              label: item.label,
              active: isActive,
              onPressed: item.onTap,
              subItems: item.subItems,
            );
          }),
        ),
      ),
    );
  }
}

class HeaderSubMenuItemData {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const HeaderSubMenuItemData({
    required this.label,
    this.icon,
    required this.onTap,
  });
}

class HeaderMenuItemData {
  final String label;
  final VoidCallback? onTap;
  final List<HeaderSubMenuItemData>? subItems;

  const HeaderMenuItemData({required this.label, this.onTap, this.subItems});
}

class HeaderMenuItem extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback? onPressed;
  final List<HeaderSubMenuItemData>? subItems;

  const HeaderMenuItem({
    super.key,
    required this.label,
    this.active = false,
    this.onPressed,
    this.subItems,
  });

  @override
  State<HeaderMenuItem> createState() => _HeaderMenuItemState();
}

class _HeaderMenuItemState extends State<HeaderMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = widget.active;
    final hasSubItems = widget.subItems != null && widget.subItems!.isNotEmpty;

    final labelWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
        if (hasSubItems) ...[
          const SizedBox(width: 2),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );

    Widget childWidget;

    if (hasSubItems) {
      childWidget = PopupMenuButton<HeaderSubMenuItemData>(
        tooltip: widget.label,
        offset: const Offset(0, 38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (subItem) => subItem.onTap(),
        itemBuilder: (context) {
          return widget.subItems!.map((subItem) {
            return PopupMenuItem<HeaderSubMenuItemData>(
              value: subItem,
              child: Row(
                children: [
                  if (subItem.icon != null) ...[
                    Icon(subItem.icon, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    subItem.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: labelWidget,
        ),
      );
    } else {
      childWidget = TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: widget.onPressed,
        child: labelWidget,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsetsDirectional.only(end: 4),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer.withValues(alpha: 0.55)
              : (_hovered
                    ? colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.65,
                      )
                    : colorScheme.surface.withValues(alpha: 0.0)),
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border(bottom: BorderSide(color: colorScheme.primary, width: 2))
              : null,
        ),
        child: childWidget,
      ),
    );
  }
}

class HeaderSearch extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const HeaderSearch({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'البحث داخل النظام...',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localController = controller;
    final hasText = localController?.text.isNotEmpty ?? false;

    return SizedBox(
      height: 40,
      child: TextField(
        controller: localController,
        onChanged: onChanged,
        textAlign: TextAlign.start,
        textDirection: Directionality.of(context),
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.outline),
          suffixIcon: hasText
              ? IconButton(
                  onPressed: () {
                    if (localController != null) {
                      localController.clear();
                      onChanged?.call('');
                    }
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  splashRadius: 18,
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.72,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          isDense: true,
        ),
      ),
    );
  }
}

class LogoutButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool confirmBeforeLogout;
  final String tooltip;

  const LogoutButton({
    super.key,
    this.onPressed,
    this.confirmBeforeLogout = true,
    this.tooltip = 'تسجيل الخروج',
  });

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool _hovered = false;

  Future<void> _handleTap(BuildContext context) async {
    final navigator = Navigator.of(context);
    final authCubit = context.read<AuthCubit>();
    final bool shouldProceed;

    if (!widget.confirmBeforeLogout) {
      shouldProceed = true;
    } else {
      shouldProceed =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              final dialogColorScheme = Theme.of(dialogContext).colorScheme;

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                title: Text(
                  'تسجيل الخروج',
                  style: Theme.of(dialogContext).textTheme.titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: dialogColorScheme.onSurface,
                      ),
                ),
                content: Text(
                  'هل تريد تسجيل الخروج من التطبيق؟',
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                    color: dialogColorScheme.onSurfaceVariant,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('تسجيل الخروج'),
                  ),
                ],
              );
            },
          ) ??
          false;
    }

    if (!shouldProceed) {
      return;
    }

    if (!mounted) {
      return;
    }

    if (widget.onPressed != null) {
      widget.onPressed!.call();
      return;
    }

    authCubit.logout();

    if (!mounted) {
      return;
    }

    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _hovered
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.65)
                : colorScheme.surface.withValues(alpha: 0.0),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: IconButton(
            onPressed: () => _handleTap(context),
            tooltip: widget.tooltip,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: Icon(
              Icons.logout_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
