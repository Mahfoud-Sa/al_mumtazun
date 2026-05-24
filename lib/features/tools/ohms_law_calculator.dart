import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class OhmsLawCalculator extends StatefulWidget {
  const OhmsLawCalculator({super.key});

  @override
  State<OhmsLawCalculator> createState() => _OhmsLawCalculatorState();
}

class _OhmsLawCalculatorState extends State<OhmsLawCalculator> {
  int _targetIndex = 0; // 0: Voltage (V), 1: Current (I), 2: Resistance (R)

  final _input1Controller = TextEditingController();
  final _input2Controller = TextEditingController();

  double? _result;
  String _formulaText = '';

  @override
  void initState() {
    super.initState();
    _input1Controller.addListener(_calculate);
    _input2Controller.addListener(_calculate);
  }

  @override
  void dispose() {
    _input1Controller.dispose();
    _input2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final val1 = double.tryParse(_input1Controller.text.trim());
    final val2 = double.tryParse(_input2Controller.text.trim());

    if (val1 == null || val2 == null || val1 <= 0 || val2 <= 0) {
      setState(() {
        _result = null;
        _formulaText = '';
      });
      return;
    }

    double res = 0;
    String formula = '';

    if (_targetIndex == 0) {
      // Voltage (V) = I * R
      res = val1 * val2;
      formula = 'V = I × R\n$val1 A × $val2 Ω = $res V';
    } else if (_targetIndex == 1) {
      // Current (I) = V / R
      res = val1 / val2;
      formula = 'I = V ÷ R\n$val1 V ÷ $val2 Ω = ${res.toStringAsFixed(4)} A';
    } else {
      // Resistance (R) = V / I
      res = val1 / val2;
      formula = 'R = V ÷ I\n$val1 V ÷ $val2 A = ${res.toStringAsFixed(4)} Ω';
    }

    setState(() {
      _result = res;
      _formulaText = formula;
    });
  }

  void _onTargetChanged(int index) {
    setState(() {
      _targetIndex = index;
      _input1Controller.clear();
      _input2Controller.clear();
      _result = null;
      _formulaText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Field configuration depending on what is being calculated
    String input1Label = '';
    String input1Hint = '';
    String input1Unit = '';
    
    String input2Label = '';
    String input2Hint = '';
    String input2Unit = '';

    String resultLabel = '';
    String resultUnit = '';

    if (_targetIndex == 0) {
      input1Label = 'التيار الكهربائي (I)';
      input1Hint = 'مثال: 2';
      input1Unit = 'أمبير (A)';

      input2Label = 'المقاومة الكهربائية (R)';
      input2Hint = 'مثال: 10';
      input2Unit = 'أوم (Ω)';

      resultLabel = 'الجهد الكهربائي المحسوب (V)';
      resultUnit = 'فولت (V)';
    } else if (_targetIndex == 1) {
      input1Label = 'الجهد الكهربائي (V)';
      input1Hint = 'مثال: 12';
      input1Unit = 'فولت (V)';

      input2Label = 'المقاومة الكهربائية (R)';
      input2Hint = 'مثال: 6';
      input2Unit = 'أوم (Ω)';

      resultLabel = 'التيار الكهربائي المحسوب (I)';
      resultUnit = 'أمبير (A)';
    } else {
      input1Label = 'الجهد الكهربائي (V)';
      input1Hint = 'مثال: 220';
      input1Unit = 'فولت (V)';

      input2Label = 'التيار الكهربائي (I)';
      input2Hint = 'مثال: 10';
      input2Unit = 'أمبير (A)';

      resultLabel = 'المقاومة الكهربائية المحسوبة (R)';
      resultUnit = 'أوم (Ω)';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('قانون أوم (Ohm’s Law)'),
        backgroundColor: isDark ? const Color(0xFF111820) : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target selector
            Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141D26) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334050) : AppColors.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    _buildSegmentButton(0, 'الجهد (V)'),
                    _buildSegmentButton(1, 'التيار (I)'),
                    _buildSegmentButton(2, 'المقاومة (R)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'أدخل المعطيات أدناه للحساب التلقائي:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Input 1
            _buildCalculatorInput(
              controller: _input1Controller,
              label: input1Label,
              hint: input1Hint,
              unit: input1Unit,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Input 2
            _buildCalculatorInput(
              controller: _input2Controller,
              label: input2Label,
              hint: input2Hint,
              unit: input2Unit,
              isDark: isDark,
            ),
            const SizedBox(height: 36),

            // Result Display Card
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _result == null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.02)
                            : Colors.black.withValues(alpha: 0.015),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334050) : AppColors.outlineVariant,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.grey, size: 28),
                          SizedBox(height: 8),
                          Text(
                            'يرجى إدخال قيم صحيحة للبدء بالحساب التلقائي.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF39C12),
                            Color(0xFFE67E22),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF39C12).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            resultLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_result!.toStringAsFixed(_result! % 1 == 0 ? 0 : 3)} $resultUnit',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formulaText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(int index, String label) {
    final isSelected = _targetIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTargetChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF334050) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.primary)
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String unit,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              unit,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: isDark ? const Color(0xFF141D26) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334050) : AppColors.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF39C12), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
