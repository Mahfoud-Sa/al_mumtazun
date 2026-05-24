import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class VoltageDividerCalculator extends StatefulWidget {
  const VoltageDividerCalculator({super.key});

  @override
  State<VoltageDividerCalculator> createState() => _VoltageDividerCalculatorState();
}

class _VoltageDividerCalculatorState extends State<VoltageDividerCalculator> {
  final _vinController = TextEditingController();
  final _r1Controller = TextEditingController();
  final _r2Controller = TextEditingController();

  double? _vout;
  double? _current;
  String _formulaText = '';

  @override
  void initState() {
    super.initState();
    _vinController.addListener(_calculate);
    _r1Controller.addListener(_calculate);
    _r2Controller.addListener(_calculate);
  }

  @override
  void dispose() {
    _vinController.dispose();
    _r1Controller.dispose();
    _r2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final vin = double.tryParse(_vinController.text.trim());
    final r1 = double.tryParse(_r1Controller.text.trim());
    final r2 = double.tryParse(_r2Controller.text.trim());

    if (vin == null || r1 == null || r2 == null || vin < 0 || r1 <= 0 || r2 <= 0) {
      setState(() {
        _vout = null;
        _current = null;
        _formulaText = '';
      });
      return;
    }

    // Formula: Vout = Vin * (R2 / (R1 + R2))
    final vout = vin * (r2 / (r1 + r2));
    
    // Ohm's law: Current = Vin / (R1 + R2)
    final currentVal = vin / (r1 + r2); // Current in Amperes

    String currentText = '';
    if (currentVal < 0.001) {
      currentText = '${(currentVal * 1000000).toStringAsFixed(2)} µA';
    } else if (currentVal < 1) {
      currentText = '${(currentVal * 1000).toStringAsFixed(2)} mA';
    } else {
      currentText = '${currentVal.toStringAsFixed(3)} A';
    }

    final formula = 'Vout = Vin × [ R2 ÷ (R1 + R2) ]\n$vin V × [ $r2 Ω ÷ ($r1 Ω + $r2 Ω) ] = ${vout.toStringAsFixed(3)} V';

    setState(() {
      _vout = vout;
      _current = currentVal;
      _formulaText = '$formula\n\nالتيار الكلي المار: $currentText';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('مقسم الجهد (Voltage Divider)'),
        backgroundColor: isDark ? const Color(0xFF111820) : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circuit diagram
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141D26) : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334050) : AppColors.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'مخطط الدائرة الكهربائية',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Vertical diagram lines
                        Column(
                          children: [
                            // Vin node
                            _buildDiagramNode('Vin', _vinController.text.isNotEmpty ? '${_vinController.text} V' : 'Vin'),
                            _buildDiagramLine(),
                            
                            // Resistor R1
                            _buildDiagramResistor('R1', _r1Controller.text.isNotEmpty ? '${_r1Controller.text} Ω' : 'R1'),
                            _buildDiagramLine(),

                            // Vout node splitting
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(width: 24, height: 2, color: Colors.blue),
                                _buildDiagramNode('Vout', _vout != null ? '${_vout!.toStringAsFixed(2)} V' : 'Vout', isOutput: true),
                              ],
                            ),
                            
                            _buildDiagramLine(),

                            // Resistor R2
                            _buildDiagramResistor('R2', _r2Controller.text.isNotEmpty ? '${_r2Controller.text} Ω' : 'R2'),
                            _buildDiagramLine(),

                            // GND
                            _buildDiagramNode('GND', '0 V', isGnd: true),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form inputs
            Text(
              'أدخل معطيات المقسم الكهربائي أدناه:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildCalculatorInput(
              controller: _vinController,
              label: 'جهد الدخل (Vin)',
              hint: 'مثال: 12',
              unit: 'فولت (V)',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _buildCalculatorInput(
              controller: _r1Controller,
              label: 'المقاومة الأولى (R1)',
              hint: 'مثال: 10000',
              unit: 'أوم (Ω)',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _buildCalculatorInput(
              controller: _r2Controller,
              label: 'المقاومة الثانية (R2)',
              hint: 'مثال: 10000',
              unit: 'أوم (Ω)',
              isDark: isDark,
            ),
            const SizedBox(height: 36),

            // Output Display Card
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _vout == null
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
                            Color(0xFF0288D1),
                            Color(0xFF01579B),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0288D1).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'جهد الخرج المحسوب (Vout)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_vout!.toStringAsFixed(_vout! % 1 == 0 ? 0 : 3)} فولت (V)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
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

  Widget _buildDiagramNode(String symbol, String value, {bool isOutput = false, bool isGnd = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOutput 
            ? Colors.blue.withValues(alpha: 0.15) 
            : (isGnd ? Colors.grey[700] : Colors.grey.withValues(alpha: 0.1)),
        border: Border.all(
          color: isOutput ? Colors.blue : (isGnd ? Colors.grey[800]! : Colors.grey[400]!),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$symbol: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isOutput ? Colors.blue : (isGnd ? Colors.white : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDiagramLine() {
    return Container(width: 2, height: 20, color: Colors.grey[400]);
  }

  Widget _buildDiagramResistor(String name, String value) {
    return Container(
      width: 72,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF1D483).withValues(alpha: 0.7),
        border: Border.all(color: Colors.orange[400]!, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        ],
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
              borderSide: const BorderSide(color: Color(0xFF0288D1), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
