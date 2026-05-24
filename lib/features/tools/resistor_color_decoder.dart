import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ResistorColorDecoder extends StatefulWidget {
  const ResistorColorDecoder({super.key});

  @override
  State<ResistorColorDecoder> createState() => _ResistorColorDecoderState();
}

class _ResistorColorDecoderState extends State<ResistorColorDecoder> {
  int _band1Index = 4; // Yellow (4)
  int _band2Index = 7; // Violet (7)
  int _band3Index = 2; // Red (x100)
  int _band4Index = 5; // Gold (±5%)

  final List<_BandColor> _digitColors = [
    _BandColor('أسود', 'Black', 0, Colors.black, textOnLight: Colors.white),
    _BandColor('بني', 'Brown', 1, Colors.brown, textOnLight: Colors.white),
    _BandColor('أحمر', 'Red', 2, Colors.red, textOnLight: Colors.white),
    _BandColor('برتقالي', 'Orange', 3, Colors.orange),
    _BandColor('أصفر', 'Yellow', 4, Colors.yellow[600] ?? Colors.yellow),
    _BandColor('أخضر', 'Green', 5, Colors.green, textOnLight: Colors.white),
    _BandColor('أزرق', 'Blue', 6, Colors.blue, textOnLight: Colors.white),
    _BandColor('بنفسجي', 'Violet', 7, Colors.purple, textOnLight: Colors.white),
    _BandColor('رمادي', 'Grey', 8, Colors.grey, textOnLight: Colors.white),
    _BandColor('أبيض', 'White', 9, Colors.white, border: Colors.black26),
  ];

  final List<_BandColor> _multiplierColors = [
    _BandColor('أسود', 'Black (x1)', 1, Colors.black, textOnLight: Colors.white),
    _BandColor('بني', 'Brown (x10)', 10, Colors.brown, textOnLight: Colors.white),
    _BandColor('أحمر', 'Red (x100)', 100, Colors.red, textOnLight: Colors.white),
    _BandColor('برتقالي', 'Orange (x1k)', 1000, Colors.orange),
    _BandColor('أصفر', 'Yellow (x10k)', 10000, Colors.yellow[600] ?? Colors.yellow),
    _BandColor('أخضر', 'Green (x100k)', 100000, Colors.green, textOnLight: Colors.white),
    _BandColor('أزرق', 'Blue (x1M)', 1000000, Colors.blue, textOnLight: Colors.white),
    _BandColor('بنفسجي', 'Violet (x10M)', 10000000, Colors.purple, textOnLight: Colors.white),
    _BandColor('ذهبي', 'Gold (x0.1)', 0.1, const Color(0xFFD4AF37)),
    _BandColor('فضي', 'Silver (x0.01)', 0.01, const Color(0xFFC0C0C0)),
  ];

  final List<_BandColor> _toleranceColors = [
    _BandColor('بني', 'Brown (±1%)', 1, Colors.brown, textOnLight: Colors.white),
    _BandColor('أحمر', 'Red (±2%)', 2, Colors.red, textOnLight: Colors.white),
    _BandColor('أخضر', 'Green (±0.5%)', 0.5, Colors.green, textOnLight: Colors.white),
    _BandColor('أزرق', 'Blue (±0.25%)', 0.25, Colors.blue, textOnLight: Colors.white),
    _BandColor('بنفسجي', 'Violet (±0.1%)', 0.1, Colors.purple, textOnLight: Colors.white),
    _BandColor('ذهبي', 'Gold (±5%)', 5, const Color(0xFFD4AF37)),
    _BandColor('فضي', 'Silver (±10%)', 10, const Color(0xFFC0C0C0)),
  ];

  String _calculateResistance() {
    final digit1 = _digitColors[_band1Index].value.toInt();
    final digit2 = _digitColors[_band2Index].value.toInt();
    final multiplier = _multiplierColors[_band3Index].value;
    final tolerance = _toleranceColors[_band4Index].value;

    final baseValue = (digit1 * 10 + digit2) * multiplier;
    
    String formattedValue = '';
    if (baseValue >= 1000000) {
      formattedValue = '${(baseValue / 1000000).toStringAsFixed(baseValue % 1000000 == 0 ? 0 : 2)} MΩ';
    } else if (baseValue >= 1000) {
      formattedValue = '${(baseValue / 1000).toStringAsFixed(baseValue % 1000 == 0 ? 0 : 2)} kΩ';
    } else {
      formattedValue = '${baseValue.toStringAsFixed(baseValue % 1 == 0 ? 0 : 2)} Ω';
    }

    return '$formattedValue ± $tolerance%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resultText = _calculateResistance();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('حاسبة ألوان المقاومات'),
        backgroundColor: isDark ? const Color(0xFF111820) : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resistor Visual Drawing
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141D26) : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334050) : AppColors.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left lead
                    Container(width: 40, height: 4, color: Colors.grey[400]),
                    
                    // Resistor body
                    Container(
                      width: 180,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFFE5C158) : const Color(0xFFF1D483),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Band 1
                          Positioned(
                            left: 24,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              color: _digitColors[_band1Index].color,
                            ),
                          ),
                          // Band 2
                          Positioned(
                            left: 56,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              color: _digitColors[_band2Index].color,
                            ),
                          ),
                          // Band 3
                          Positioned(
                            left: 88,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              color: _multiplierColors[_band3Index].color,
                            ),
                          ),
                          // Band 4
                          Positioned(
                            right: 28,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              color: _toleranceColors[_band4Index].color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Right lead
                    Container(width: 40, height: 4, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Decoded Output Value Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF1B5E20),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'قيمة المقاومة المفككة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resultText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'اختر ألوان الحلقات أدناه لتغيير القيمة:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dropdown Band 1
            _buildBandSelector(
              index: _band1Index,
              label: 'الحلقة الأولى (الرقم الأول)',
              items: _digitColors,
              isDark: isDark,
              onChanged: (val) => setState(() => _band1Index = val!),
            ),
            const SizedBox(height: 16),

            // Dropdown Band 2
            _buildBandSelector(
              index: _band2Index,
              label: 'الحلقة الثانية (الرقم الثاني)',
              items: _digitColors,
              isDark: isDark,
              onChanged: (val) => setState(() => _band2Index = val!),
            ),
            const SizedBox(height: 16),

            // Dropdown Band 3
            _buildBandSelector(
              index: _band3Index,
              label: 'الحلقة الثالثة (المضاعف)',
              items: _multiplierColors,
              isDark: isDark,
              onChanged: (val) => setState(() => _band3Index = val!),
            ),
            const SizedBox(height: 16),

            // Dropdown Band 4
            _buildBandSelector(
              index: _band4Index,
              label: 'الحلقة الرابعة (نسبة الخطأ)',
              items: _toleranceColors,
              isDark: isDark,
              onChanged: (val) => setState(() => _band4Index = val!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBandSelector({
    required int index,
    required String label,
    required List<_BandColor> items,
    required bool isDark,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141D26) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334050) : AppColors.outline,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: index,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF141D26) : Colors.white,
              onChanged: onChanged,
              items: List.generate(items.length, (i) {
                final colorItem = items[i];
                return DropdownMenuItem<int>(
                  value: i,
                  child: Row(
                    children: [
                      // Color dot indicator
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colorItem.color,
                          shape: BoxShape.circle,
                          border: colorItem.border != null
                              ? Border.all(color: colorItem.border!, width: 1.5)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${colorItem.arabicName} (${colorItem.englishName})',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _BandColor {
  final String arabicName;
  final String englishName;
  final double value;
  final Color color;
  final Color? textOnLight;
  final Color? border;

  _BandColor(
    this.arabicName,
    this.englishName,
    this.value,
    this.color, {
    this.textOnLight,
    this.border,
  });
}
