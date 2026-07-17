import 'package:engineering_ops_dashboard/core/widgets/primery_button_widget.dart';
import 'package:engineering_ops_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DesktopSidebar extends StatefulWidget {
  final List<DesktopNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Widget? action;
  final Widget? footer;
  final String brandTitle;
  final String brandSubtitle;

  const DesktopSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.action,
    this.footer,
    this.brandTitle = 'المتميزون',
    this.brandSubtitle = 'لوحة العمليات',
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  bool isCollapsed = false;

  void _toggleCollapsed() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actionWidget =
        widget.action ?? PrimeryButtonWidget(compact: isCollapsed);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 260,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: BorderDirectional(
          end: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(8, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 44,
            child: _SidebarHeader(
              title: widget.brandTitle,
              subtitle: widget.brandSubtitle,
              isCollapsed: isCollapsed,
              onToggle: _toggleCollapsed,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isCollapsed
                ? SizedBox(
                    key: const ValueKey('collapsed-action'),
                    height: 44,
                    width: double.infinity,
                    child: Center(
                      child: Tooltip(
                        message: 'إضافة جهاز جديد',
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'إضافة جهاز جديد',
                          onPressed: () {},
                          icon: Icon(
                            Icons.add,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('expanded-action'),
                    width: double.infinity,
                    child: actionWidget,
                  ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isCollapsed
                ? const SizedBox.shrink(key: ValueKey('section-collapsed'))
                : Padding(
                    key: const ValueKey('section-expanded'),
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: Text(
                      'القائمة',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: widget.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _SidebarNavTile(
                  item: item,
                  selected: index == widget.selectedIndex,
                  collapsed: isCollapsed,
                  onTap: () => widget.onItemSelected(index),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isCollapsed
                ? SizedBox(
                    key: const ValueKey('collapsed-footer'),
                    height: 44,
                    child: Center(
                      child: Tooltip(
                        message: 'معلومات',
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'معلومات',
                          onPressed: () {},
                          icon: Icon(
                            Icons.info_outline,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                : (widget.footer ?? _DefaultFooter()),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const _SidebarHeader({
    required this.title,
    required this.subtitle,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,

        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },

        child: isCollapsed
            ? _CollapsedHeader(
                key: const ValueKey('collapsed-header'),
                onToggle: onToggle,
              )
            : _ExpandedHeader(
                key: const ValueKey('expanded-header'),
                title: title,
                subtitle: subtitle,
                colorScheme: colorScheme,
                onToggle: onToggle,
              ),
      ),
    );
  }
}

class _CollapsedHeader extends StatelessWidget {
  final VoidCallback onToggle;

  const _CollapsedHeader({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(14),

      child: Center(
        child: Container(
          width: 50,
          height: 50,

          alignment: Alignment.center,

          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),

          child: Image.asset(
            'assets/images/another.png',
            width: 44,
            height: 44,
          ),
        ),
      ),
    );
  }
}

class _ExpandedHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final VoidCallback onToggle;

  const _ExpandedHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,

      children: [
        // Logo
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            alignment: Alignment.center,

            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Image.asset(
              'assets/images/another.png',
              width: 32,
              height: 32,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Text section
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,

                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 6),

        // Collapse button
        _SidebarToggleButton(isCollapsed: false, onPressed: onToggle),
      ],
    );
  }
}

class _SidebarToggleButton extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onPressed;

  const _SidebarToggleButton({
    required this.isCollapsed,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        hoverColor: colorScheme.secondaryContainer.withValues(alpha: 0.35),
        splashColor: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.fastOutSlowIn,
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Icon(
              isCollapsed ? Icons.chevron_right : Icons.chevron_left,
              key: ValueKey(isCollapsed),
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarNavTile extends StatefulWidget {
  final DesktopNavItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarNavTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  State<_SidebarNavTile> createState() => _SidebarNavTileState();
}

class _SidebarNavTileState extends State<_SidebarNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = widget.selected;
    final collapsed = widget.collapsed;
    final baseColor = selected
        ? AppColors.secondaryContainer
        : (_hovered ? colorScheme.surfaceContainerHighest : Colors.transparent);
    final iconColor = selected
        ? colorScheme.primary
        : (_hovered ? colorScheme.onSurface : colorScheme.onSurfaceVariant);

    final tileContent = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onTap,
        hoverColor: colorScheme.secondaryContainer.withValues(alpha: 0.35),
        splashColor: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: collapsed
                ? SizedBox(
                    key: const ValueKey('nav-collapsed'),
                    width: 44,
                    height: 24,
                    child: Center(
                      child: Tooltip(
                        message: widget.item.label,
                        child: Icon(
                          selected
                              ? (widget.item.selectedIcon ?? widget.item.icon)
                              : widget.item.icon,
                          size: 22,
                          color: iconColor,
                        ),
                      ),
                    ),
                  )
                : Row(
                    key: const ValueKey('nav-expanded'),
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        width: selected ? 4 : 0,
                        height: 22,
                        margin: EdgeInsetsDirectional.only(
                          end: selected ? 10 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          selected
                              ? (widget.item.selectedIcon ?? widget.item.icon)
                              : widget.item.icon,
                          key: ValueKey(selected),
                          size: 20,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: selected
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            if (widget.item.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.item.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.item.badgeCount != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.item.badgeCount.toString(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(14),
        ),
        transform: Matrix4.translationValues(
          0.0,
          _hovered && !selected ? -1 : 0,
          0.0,
        ),
        child: tileContent,
      ),
    );
  }
}

class _DefaultFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'جميع الحقوق محفوظة © 2024',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopNavItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? description;
  final int? badgeCount;

  const DesktopNavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.description,
    this.badgeCount,
  });
}
