import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showDrawerButton;
  final bool showSearch;
  final bool showDesktopMenus;
  final String username;
  final String userInitial;
  final VoidCallback? onDrawerPressed;
  final VoidCallback? onProfilePressed;
  final List<HeaderMenuItemData> menuItems;
  final int? selectedMenuIndex;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHintText;

  const AppHeader({
    super.key,
    required this.title,
    required this.username,
    required this.userInitial,
    this.showDrawerButton = false,
    this.showSearch = true,
    this.showDesktopMenus = true,
    this.onDrawerPressed,
    this.onProfilePressed,
    this.menuItems = const [],
    this.selectedMenuIndex,
    this.searchController,
    this.onSearchChanged,
    this.searchHintText = 'البحث داخل النظام...',
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
        //   color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: colorScheme.shadow.withValues(alpha: 0.06),
        //     blurRadius: 12,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final showMenus = showDesktopMenus && width >= 920;
            final showSearch = this.showSearch && width >= 760;
            final showUsername = width >= 620;

            return Row(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (showDrawerButton) ...[
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onDrawerPressed,
                    icon: Icon(Icons.menu, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                ] else
                  const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.dashboard_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
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
                const SizedBox(width: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: showMenus
                      ? SizedBox(
                          key: const ValueKey('menus-visible'),
                          child: HeaderMenu(
                            items: menuItems.isNotEmpty
                                ? menuItems
                                : const [
                                    HeaderMenuItemData(label: 'ملف'),
                                    HeaderMenuItemData(label: 'تعديل'),
                                    HeaderMenuItemData(label: 'عرض'),
                                    HeaderMenuItemData(label: 'الأدوات'),
                                    HeaderMenuItemData(label: 'مساعدة'),
                                  ],
                            selectedIndex: selectedMenuIndex,
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('menus-hidden')),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: showSearch
                      ? ConstrainedBox(
                          key: const ValueKey('search-visible'),
                          constraints: const BoxConstraints(
                            minWidth: 150,
                            maxWidth: 280,
                          ),
                          child: LayoutBuilder(
                            builder: (context, innerConstraints) {
                              final preferredWidth = math.min(
                                280.0,
                                math.max(
                                  150.0,
                                  innerConstraints.maxWidth * 0.28,
                                ),
                              );
                              return SizedBox(
                                width: preferredWidth,
                                child: HeaderSearch(
                                  controller: searchController,
                                  onChanged: onSearchChanged,
                                  hintText:
                                      searchHintText ?? 'البحث داخل النظام...',
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('search-hidden')),
                ),
                const SizedBox(width: 12),
                UserProfileButton(
                  username: username,
                  userInitial: userInitial,
                  showUsername: showUsername,
                  onPressed: onProfilePressed,
                ),
              ],
            );
          },
        ),
      ),
    );
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 0,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = selectedIndex != null && index == selectedIndex;

          return HeaderMenuItem(
            label: item.label,
            active: isActive,
            onPressed: item.onTap,
          );
        }),
      ),
    );
  }
}

class HeaderMenuItemData {
  final String label;
  final VoidCallback? onTap;

  const HeaderMenuItemData({required this.label, this.onTap});
}

class HeaderMenuItem extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback? onPressed;

  const HeaderMenuItem({
    super.key,
    required this.label,
    this.active = false,
    this.onPressed,
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

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer
              : (_hovered
                    ? colorScheme.secondaryContainer.withValues(alpha: 0.5)
                    : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: widget.onPressed,
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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

    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.start,
        textDirection: Directionality.of(context),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: colorScheme.outline),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.3),
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

class UserProfileButton extends StatelessWidget {
  final String username;
  final String userInitial;
  final bool showUsername;
  final VoidCallback? onPressed;

  const UserProfileButton({
    super.key,
    required this.username,
    required this.userInitial,
    this.showUsername = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  userInitial,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: showUsername
                    ? Padding(
                        key: const ValueKey('profile-name'),
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: Text(
                          username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('profile-name-hidden'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
