import 'package:engineering_ops_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'state/home_cubit.dart';

class DesktopSidebar extends StatelessWidget {
  final List<DesktopNavItem> items;

  const DesktopSidebar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.surfaceContainerLow,

      child: Column(
        children: [
          const SizedBox(height: 40),

          Image.asset("assets/images/another.png", width: 120),

          const SizedBox(height: 30),

          Expanded(
            child: BlocBuilder<HomeCubit, int>(
              builder: (context, index) {
                return ListView.separated(
                  itemCount: items.length,

                  separatorBuilder: (_, __) => const SizedBox(height: 8),

                  itemBuilder: (context, i) {
                    final item = items[i];

                    final selected = index == i;

                    return Material(
                      color: Colors.transparent,

                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),

                        hoverColor: AppColors.surfaceContainerHigh,

                        splashColor: AppColors.secondaryContainer,

                        onTap: () {
                          context.read<HomeCubit>().setIndex(i);
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),

                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.secondaryContainer
                                : Colors.transparent,

                            borderRadius: BorderRadius.circular(12),

                            border: selected
                                ? Border.all(
                                    color: AppColors.secondary,
                                    width: 1.5,
                                  )
                                : null,
                          ),

                          child: Row(
                            children: [
                              Icon(
                                item.icon,

                                size: 22,

                                color: selected
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Text(
                                  item.label,

                                  style: TextStyle(
                                    fontSize: 15,

                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.normal,

                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
