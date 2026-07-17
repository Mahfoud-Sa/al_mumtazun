import 'package:engineering_ops_dashboard/core/widgets/primery_button_widget.dart';
import 'package:engineering_ops_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DesktopSidebar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actionWidget = action ?? const PrimeryButtonWidget();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 280,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
          _BrandHeader(title: brandTitle, subtitle: brandSubtitle),
          const SizedBox(height: 20),
          actionWidget,
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: Text(
              'القائمة',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return _SidebarNavTile(
                  item: item,
                  selected: index == selectedIndex,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          footer ?? _DefaultFooter(),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _BrandHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Image.asset(
            'assets/images/another.png',
            width: 28,
            height: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarNavTile extends StatefulWidget {
  final DesktopNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarNavTile({
    required this.item,
    required this.selected,
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
    final baseColor = selected
        ? AppColors.secondaryContainer
        : (_hovered ? colorScheme.surfaceContainerHighest : Colors.transparent);
    final iconColor = selected
        ? colorScheme.primary
        : (_hovered ? colorScheme.onSurface : colorScheme.onSurfaceVariant);
    final textColor = selected
        ? colorScheme.primary
        : (_hovered ? colorScheme.onSurface : colorScheme.onSurfaceVariant);

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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onTap,
            hoverColor: colorScheme.secondaryContainer.withValues(alpha: 0.35),
            splashColor: colorScheme.secondaryContainer.withValues(alpha: 0.45),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: selected ? 4 : 0,
                    height: 22,
                    margin: EdgeInsetsDirectional.only(end: selected ? 10 : 0),
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
                                color: textColor,
                              ),
                        ),
                        if (widget.item.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.item.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
