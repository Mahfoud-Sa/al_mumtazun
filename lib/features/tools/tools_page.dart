import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'ohms_law_calculator.dart';
import 'resistor_color_decoder.dart';
import 'voltage_divider_calculator.dart';
import 'power_calculator.dart';

class EngineeringToolsPage extends StatelessWidget {
  const EngineeringToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final toolItems = [
      _ToolItem(
        title: 'قانون أوم',
        englishTitle: "Ohm's Law",
        description:
            'حساب الجهد، التيار، والمقاومة الكهربائية بشكل تفاعلي سريع.',
        icon: Icons.flash_on_rounded,
        gradientColors: [const Color(0xFFF39C12), const Color(0xFFE67E22)],
        page: const OhmsLawCalculator(),
      ),
      _ToolItem(
        title: 'ألوان المقاومات',
        englishTitle: 'Resistor Decoder',
        description:
            'تحديد قيمة المقاومة الكهربائية ونسبة الخطأ من خلال ألوان الحلقات.',
        icon: Icons.palette_rounded,
        gradientColors: [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
        page: const ResistorColorDecoder(),
      ),
      _ToolItem(
        title: 'مقسم الجهد',
        englishTitle: 'Voltage Divider',
        description:
            'حساب الجهد الناتج عن توزيع المقاومات مع رسم توضيحي للدائرة.',
        icon: Icons.alt_route_rounded,
        gradientColors: [const Color(0xFF0288D1), const Color(0xFF01579B)],
        page: const VoltageDividerCalculator(),
      ),
      _ToolItem(
        title: 'حاسبة القدرة',
        englishTitle: 'Power Calculator',
        description:
            'حساب القدرة الكهربائية بالواط والجهد والتيار بناءً على معادلات الطاقة.',
        icon: Icons.bolt_rounded,
        gradientColors: [const Color(0xFFD32F2F), const Color(0xFFB71C1C)],
        page: const PowerCalculator(),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'الأدوات الهندسية',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF111820) : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ادوات لمساعدتك في حساب القيم الالكترونية",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primary,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'اختر الأداة المطلوبة لبدء الحسابات الفورية بدقة عالية.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? const Color(0xFFB8C2CC)
                    : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
                  final childAspectRatio = constraints.maxWidth > 700
                      ? 1.6
                      : 1.45;

                  return GridView.builder(
                    itemCount: toolItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final item = toolItems[index];
                      return _ToolCard(item: item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final String englishTitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Widget page;

  _ToolItem({
    required this.title,
    required this.englishTitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.page,
  });
}

class _ToolCard extends StatefulWidget {
  final _ToolItem item;
  const _ToolCard({required this.item});

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => widget.item.page));
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141D26) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334050)
                  : AppColors.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Top-right glowing shape
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.item.gradientColors
                            .map((c) => c.withValues(alpha: 0.15))
                            .toList(),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.item.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              widget.item.icon,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                widget.item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.item.englishTitle,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.item.description,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
