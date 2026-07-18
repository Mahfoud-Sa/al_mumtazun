import 'package:flutter/material.dart';

class DesktopProfileCard extends StatefulWidget {
  final String name;
  final String role;
  final String? imageUrl;
  final VoidCallback onTap;

  const DesktopProfileCard({
    super.key,
    required this.name,
    required this.role,
    this.imageUrl,
    required this.onTap,
  });

  @override
  State<DesktopProfileCard> createState() => _DesktopProfileCardState();
}

class _DesktopProfileCardState extends State<DesktopProfileCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final background = _hovered
        ? colorScheme.surfaceContainerHighest
        : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -1 : 0, 0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            hoverColor: colorScheme.secondaryContainer.withValues(alpha: .35),
            splashColor: colorScheme.secondaryContainer.withValues(alpha: .45),
            onTap: widget.onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: widget.imageUrl != null
                      ? NetworkImage(widget.imageUrl!)
                      : null,
                  child: widget.imageUrl == null
                      ? Text(
                          widget.name.characters.first.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),

                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.role,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                //  const SizedBox(width: 12),
                // AnimatedRotation(
                //   duration: const Duration(milliseconds: 180),
                //   curve: Curves.easeOutCubic,
                //   turns: _hovered ? 0.125 : 0,
                //   child: Icon(
                //     Icons.keyboard_arrow_down_rounded,
                //     color: colorScheme.onSurfaceVariant,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
