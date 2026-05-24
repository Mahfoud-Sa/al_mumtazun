import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PowerCalculator extends StatefulWidget {
  const PowerCalculator({super.key});

  @override
  State<PowerCalculator> createState() => _PowerCalculatorState();
}

class _PowerCalculatorState extends State<PowerCalculator> {
  int _targetIndex = 0; // 0: Power (P), 1: Voltage (V), 2: Current (I), 3: Resistance (R)
  int _formulaPath = 0; // 0: Formula Option A, 1: Option B, 2: Option C

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
      // Calculating Power (P) in Watts
      if (_formulaPath == 0) {
        // P = V * I
        res = val1 * val2;
        formula = 'P = V × I\n$val1 V × $val2 A = $res W';
      } else if (_formulaPath == 1) {
        // P = I^2 * R
        res = math.pow(val1, 2) * val2;
        formula = 'P = I² × R\n$val1² A × $val2 Ω = ${res.toStringAsFixed(3)} W';
      } else {
        // P = V^2 / R
        res = math.pow(val1, 2) / val2;
        formula = 'P = V² ÷ R\n$val1² V ÷ $val2 Ω = ${res.toStringAsFixed(3)} W';
      }
    } else if (_targetIndex == 1) {
      // Calculating Voltage (V) in Volts
      if (_formulaPath == 0) {
        // V = P / I
        res = val1 / val2;
        formula = 'V = P ÷ I\n$val1 W ÷ $val2 A = ${res.toStringAsFixed(3)} V';
      } else if (_formulaPath == 1) {
        // V = I * R
        res = val1 * val2;
        formula = 'V = I × R\n$val1 A × $val2 Ω = $res V';
      } else {
        // V = sqrt(P * R)
        res = math.sqrt(val1 * val2);
        formula = 'V = √(P × R)\n√($val1 W × $val2 Ω) = ${res.toStringAsFixed(3)} V';
      }
    } else if (_targetIndex == 2) {
      // Calculating Current (I) in Amps
      if (_formulaPath == 0) {
        // I = P / V
        res = val1 / val2;
        formula = 'I = P ÷ V\n$val1 W ÷ $val2 V = ${res.toStringAsFixed(3)} A';
      } else if (_formulaPath == 1) {
        // I = V / R
        res = val1 / val2;
        formula = 'I = V ÷ R\n$val1 V ÷ $val2 Ω = ${res.toStringAsFixed(3)} A';
      } else {
        // I = sqrt(P / R)
        res = math.sqrt(val1 / val2);
        formula = 'I = √(P ÷ R)\n√($val1 W ÷ $val2 Ω) = ${res.toStringAsFixed(3)} A';
      }
    } else {
      // Calculating Resistance (R) in Ohms
      if (_formulaPath == 0) {
        // R = V / I
        res = val1 / val2;
        formula = 'R = V ÷ I\n$val1 V ÷ $val2 A = ${res.toStringAsFixed(3)} Ω';
      } else if (_formulaPath == 1) {
        // R = P / I^2
        res = val1 / math.pow(val2, 2);
        formula = 'R = P ÷ I²\n$val1 W ÷ $val2² A = ${res.toStringAsFixed(3)} Ω';
      } else {
        // R = V^2 / P
        res = math.pow(val1, 2) / val2;
        formula = 'R = V² ÷ P\n$val1² V ÷ $val2 W = ${res.toStringAsFixed(3)} Ω';
      }
    }

    setState(() {
      _result = res;
      _formulaText = formula;
    });
  }

  void _onTargetIndexChanged(int index) {
    setState(() {
      _targetIndex = index;
      _formulaPath = 0;
      _input1Controller.clear();
      _input2Controller.clear();
      _result = null;
      _formulaText = '';
    });
  }

  void _onFormulaPathChanged(int? path) {
    if (path == null) return;
    setState(() {
      _formulaPath = path;
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

    // Determine path descriptions and variable mappings
    List<String> paths = [];
    String input1Label = '';
    String input1Hint = '';
    String input1Unit = '';
    
    String input2Label = '';
    String input2Hint = '';
    String input2Unit = '';

    String resultLabel = '';
    String resultUnit = '';

    if (_targetIndex == 0) {
      // Target: Power (P)
      paths = ['بمعلومية الجهد والتيار (V, I)', 'بمعلومية التيار والمقاومة (I, R)', 'بمعلومية الجهد والمقاومة (V, R)'];
      resultLabel = 'القدرة الكهربائية المحسوبة (P)';
      resultUnit = 'واط (W)';

      if (_formulaPath == 0) {
        input1Label = 'الجهد الكهربائي (V)';
        input1Hint = 'مثال: 12';
        input1Unit = 'فولت (V)';

        input2Label = 'التيار الكهربائي (I)';
        input2Hint = 'مثال: 2';
        input2Unit = 'أمبير (A)';
      } else if (_formulaPath == 1) {
        input1Label = 'التيار الكهربائي (I)';
        input1Hint = 'مثال: 3';
        input1Unit = 'أمبير (A)';

        input2Label = 'المقاومة الكهربائية (R)';
        input2Hint = 'مثال: 8';
        input2Unit = 'أوم (Ω)';
      } else {
        input1Label = 'الجهد الكهربائي (V)';
        input1Hint = 'مثال: 220';
        input1Unit = 'فولت (V)';

        input2Label = 'المقاومة الكهربائية (R)';
        input2Hint = 'مثال: 22';
        input2Unit = 'أوم (Ω)';
      }
    } else if (_targetIndex == 1) {
      // Target: Voltage (V)
      paths = ['بمعلومية القدرة والتيار (P, I)', 'بمعلومية التيار والمقاومة (I, R)', 'بمعلومية القدرة والمقاومة (P, R)'];
      resultLabel = 'الجهد الكهربائي المحسوب (V)';
      resultUnit = 'فولت (V)';

      if (_formulaPath == 0) {
        input1Label = 'القدرة الكهربائية (P)';
        input1Hint = 'مثال: 50';
        input1Unit = 'واط (W)';

        input2Label = 'التيار الكهربائي (I)';
        input2Hint = 'مثال: 2.5';
        input2Unit = 'أمبير (A)';
      } else if (_formulaPath == 1) {
        input1Label = 'التيار الكهربائي (I)';
        input1Hint = 'مثال: 4';
        input1Unit = 'أمبير (A)';

        input2Label = 'المقاومة الكهربائية (R)';
        input2Hint = 'مثال: 12';
        input2Unit = 'أوم (Ω)';
      } else {
        input1Label = 'القدرة الكهربائية (P)';
        input1Hint = 'مثال: 100';
        input1Unit = 'واط (W)';

        input2Label = 'المقاومة الكهربائية (R)';
        input2Hint = 'مثال: 4';
        input2Unit = 'أوم (Ω)';
      }
    } else if (_targetIndex == 2) {
      // Target: Current (I)
      paths = ['بمعلومية القدرة والجهد (P, V)', 'بمعلومية الجهد والمقاومة (V, R)', 'بمعلومية القدرة والمقاومة (P, R)'];
      resultLabel = 'التيار الكهربائي المحسوب (I)';
      resultUnit = 'أمبير (A)';

      if (_formulaPath == 0) {
        input1Label = 'القدرة الكهربائية (P)';
        input1Hint = 'مثال: 120';
        input1Unit = 'واط (W)';

        input2Label = 'الجهد الكهربائي (V)';
        input2Hint = 'مثال: 12';
        input2Unit = 'فولت (V)';
      } else if (_formulaPath == 1) {
        input1Label = 'الجهد الكهربائي (V)';
        input1Hint = 'مثال: 220';
        input1Unit = 'فولت (V)';

        input2Label = 'المقاومة الكهربائية (R)';
        input2Hint = 'مثال: 44';
        input2Unit = 'أوم (Ω)';
      } else {
        input1Label = 'القدرة الكهربائية (P)';
        input1Hint = 'مثال: 60';
        input1Unit = 'واط (W)';

        input2Label = 'المقاومة الكهربائية (R)';
        input2Hint = 'مثال: 15';
        input2Unit = 'أوم (Ω)';
      }
    } else {
      // Target: Resistance (R)
      paths = ['بمعلومية الجهد والتيار (V, I)', 'بمعلومية القدرة والتيار (P, I)', 'بمعلومية الجهد والقدرة (V, P)'];
      resultLabel = 'المقاومة الكهربائية المحسوبة (R)';
      resultUnit = 'أوم (Ω)';

      if (_formulaPath == 0) {
        input1Label = 'الجهد الكهربائي (V)';
        input1Hint = 'مثال: 24';
        input1Unit = 'فولت (V)';

        input2Label = 'التيار الكهربائي (I)';
        input2Hint = 'مثال: 2';
        input2Unit = 'أمبير (A)';
      } else if (_formulaPath == 1) {
        input1Label = 'القدرة الكهربائية (P)';
        input1Hint = 'مثال: 40';
        input1Unit = 'واط (W)';

        input2Label = 'التيار الكهربائي (I)';
        input2Hint = 'مثال: 2';
        input2Unit = 'أمبير (A)';
      } else {
        input1Label = 'الجهد الكهربائي (V)';
        input1Hint = 'مثال: 12';
        input1Unit = 'فولت (V)';

        input2Label = 'القدرة الكهربائية (P)';
        input2Hint = 'مثال: 36';
        input2Unit = 'واط (W)';
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('حاسبة القدرة الكهربائية'),
        backgroundColor: isDark ? const Color(0xFF111820) : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Variable to solve for
            const Text(
              'المتغير المطلوب حسابه:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSegmentButton(0, 'القدرة (P)'),
                      _buildSegmentButton(1, 'الجهد (V)'),
                      _buildSegmentButton(2, 'التيار (I)'),
                      _buildSegmentButton(3, 'المقاومة (R)'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Formula path selector dropdown
            const Text(
              'بمعلومية المتغيرات المتوفرة:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                  value: _formulaPath,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF141D26) : Colors.white,
                  onChanged: _onFormulaPathChanged,
                  items: List.generate(paths.length, (i) {
                    return DropdownMenuItem<int>(
                      value: i,
                      child: Text(
                        paths[i],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'أدخل المعطيات أدناه للحساب الفوري:',
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

            // Result Card
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
                            Color(0xFFD32F2F),
                            Color(0xFFB71C1C),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD32F2F).withValues(alpha: 0.25),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: () => _onTargetIndexChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              unit,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
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
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
