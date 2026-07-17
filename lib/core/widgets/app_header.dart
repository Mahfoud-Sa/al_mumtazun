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
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        if (showDrawerButton)
          IconButton(
            icon: Icon(Icons.menu, color: colorScheme.primary),
            onPressed: onDrawerPressed,
          ),

        if (!showDrawerButton) const SizedBox(width: 12),

        const SizedBox(width: 12),

        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(width: 32),

        if (showDesktopMenus && width > 900)
          Row(
            children: const [
              _HeaderMenuItem("ملف"),
              _HeaderMenuItem("تعديل"),
              _HeaderMenuItem("عرض"),
              _HeaderMenuItem("الأدوات"),
              _HeaderMenuItem("مساعدة"),
            ],
          ),

        const Spacer(),

        if (showSearch && width > 700)
          SizedBox(
            width: 260,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: "البحث داخل النظام...",
                prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

        const SizedBox(width: 16),

        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onProfilePressed,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  userInitial,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Text(
                username,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderMenuItem extends StatelessWidget {
  final String title;

  const _HeaderMenuItem(this.title);

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: () {}, child: Text(title));
  }
}
