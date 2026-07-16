import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state/home_cubit.dart';

class DesktopSidebar extends StatelessWidget {
  final List<DesktopNavItem> items;

  const DesktopSidebar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 260,
      color: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.asset("assets/images/another.png", width: 120),
          const SizedBox(height: 30),
          Expanded(
            child: BlocBuilder<HomeCubit, int>(
              builder: (context, index) {
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final selected = index == i;

                    return ListTile(
                      selected: selected,
                      hoverColor: colorScheme.surfaceVariant,
                      tileColor: selected
                          ? colorScheme.secondaryContainer
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: selected
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      leading: Icon(
                        item.icon,
                        color: selected ? colorScheme.primary : null,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: selected
                              ? colorScheme.onSecondaryContainer
                              : null,
                        ),
                      ),
                      selectedTileColor: colorScheme.secondaryContainer,
                      onTap: () {
                        context.read<HomeCubit>().setIndex(i);
                      },
                    );
                  },
                );
              },
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

  const DesktopNavItem({required this.label, required this.icon});
}
