import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../localization/l10n.dart';
import '../../localization/locale_cubit.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_cubit.dart';
import 'auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberDevice = false;
  bool _obscurePassword = true;
  late final Future<PackageInfo> _packageInfoFuture;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform().catchError(
      (_) => PackageInfo(
        appName: 'Engineering Ops Dashboard',
        packageName: 'com.GidTeam.app',
        version: '1.0.0',
        buildNumber: '1',
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final authCubit = context.read<AuthCubit>();

    await authCubit.login(
      phoneNumber: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final state = authCubit.state;

    if (mounted) {
      setState(() {
        _errorMessage = state.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Elegant animated background
          const BreathingBackground(),

          // Main Layout Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                
                return Center(
                  child: SingleChildScrollView(
                    child: isDesktop
                        ? _buildDesktopLayout(context, isDark, authState)
                        : _buildMobileLayout(context, isDark, authState),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, bool isDark, AuthState authState) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Brand Panel
          Expanded(
            flex: 6,
            child: _buildBrandingPanel(context, isDark),
          ),
          const SizedBox(width: 64),
          // Right side: Login Card
          Expanded(
            flex: 5,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _buildLoginFormCard(context, isDark, authState),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark, AuthState authState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mobile Top Row: Language and Theme Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LanguagePill(),
                  _buildThemeToggle(context, isDark),
                ],
              ),
              const SizedBox(height: 24),
              _buildLoginFormCard(context, isDark, authState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingPanel(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141D26).withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Header Brand
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.terminal_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'محل المتميزون',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: isDark ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'لوحة تحكم العمليات الهندسية',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? const Color(0xFFB8C2CC) : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),

          Text(
            'مرحباً بك في المنصة الهندسية المتكاملة',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isDark ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'نظام متطور لإدارة العمليات التشغيلية، ومتابعة الأجهزة الهندسية والمخزون، وتوليد الفواتير والتقارير المالية والتحليلية المتقدمة بكل سهولة ودقة.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? const Color(0xFFB8C2CC) : AppColors.onSurfaceVariant,
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 40),

          // Live Operations widgets
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'حالة النظام',
                  action: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlinkingDot(),
                      SizedBox(width: 6),
                      Text(
                        'نشط',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جميع الخدمات تعمل',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'نسبة التشغيل 100%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'أداء الشبكة',
                  child: const AnimatedSparkline(color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFormCard(BuildContext context, bool isDark, AuthState authState) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141D26)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334050)
              : AppColors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header icons for desktop
          if (isDesktop) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const LanguagePill(),
                _buildThemeToggle(context, isDark),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Centered Shield Badge
          Container(
            width: 72,
            height: 72,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : AppColors.primary.withValues(alpha: 0.04),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.08),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          Text(
            'مرحبا بعودتك',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isDark ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'يرجى إدخال بيانات الدخول الخاصة بك للمتابعة',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFFB8C2CC) : AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 32),

          // Username/Phone field
          SleekTextField(
            controller: _emailController,
            labelText: 'رقم الهاتف',
            hintText: 'مثال: 771234567',
            prefixIcon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 20),

          // Password header with Forgot password?
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'كلمة السر',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isDark ? const Color(0xFFB8C2CC) : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'نسيت كلمة السر؟',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Password textfield
          SleekTextField(
            controller: _passwordController,
            labelText: '', // Hidden since header serves as label
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.outline,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          // Error Message Alert
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Remember Me Checkbox Row
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberDevice,
                  onChanged: (val) {
                    setState(() {
                      _rememberDevice = val ?? false;
                    });
                  },
                  activeColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF8D99A6) : AppColors.outline,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'تذكرني',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? const Color(0xFFB8C2CC) : AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Login Button
          TactileButton(
            onPressed: _onLogin,
            isLoading: authState.isLoading,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'تسجيل الدخول',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Technical Support info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  BlinkingDot(),
                  SizedBox(width: 8),
                  Text(
                    'الدعم الفني',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => _showLocationDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Version/Package Info Row
          FutureBuilder<PackageInfo>(
            future: _packageInfoFuture,
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '1.0.0';
              final buildNumber = snapshot.data?.buildNumber ?? '1';

              return Text(
                'v$version (Build $buildNumber) • © 2026 جميع الحقوق محفوظة لمحل المتميزون',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? const Color(0xFF8D99A6) : const Color(0xFF8691A6),
                  fontSize: 11,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.primary.withValues(alpha: 0.04),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.08),
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? Colors.white : AppColors.primary,
          size: 18,
        ),
        onPressed: () {
          context.read<ThemeCubit>().toggle();
        },
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'موقعنا',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'حضرموت / المكلا / بويش',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }
}

// ------------------- AUXILIARY WIDGETS -------------------

class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = context.watch<LocaleCubit>().state.locale.languageCode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<LocaleCubit>().toggleEnglishArabic();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.primary.withValues(alpha: 0.04),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.08),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 16,
                color: isDark ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                locale == 'ar' ? 'English' : 'العربية',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlowingOrb extends StatelessWidget {
  final Color color;
  final double size;

  const GlowingOrb({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class BreathingBackground extends StatefulWidget {
  const BreathingBackground({super.key});

  @override
  State<BreathingBackground> createState() => _BreathingBackgroundState();
}

class _BreathingBackgroundState extends State<BreathingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double width = MediaQuery.of(context).size.width;
        final double height = MediaQuery.of(context).size.height;

        final angle = _controller.value * 2 * math.pi;
        final dx1 = math.sin(angle) * 70;
        final dy1 = math.cos(angle) * 50;
        final dx2 = math.cos(angle + 1.8) * 80;
        final dy2 = math.sin(angle + 1.8) * 60;

        return Stack(
          children: [
            Positioned(
              top: (height * 0.05) + dy1,
              left: (width * 0.05) + dx1,
              child: GlowingOrb(
                color: AppColors.primary,
                size: math.min(width * 0.45, 450),
              ),
            ),
            Positioned(
              bottom: (height * 0.08) + dy2,
              right: (width * 0.08) + dx2,
              child: GlowingOrb(
                color: AppColors.secondary,
                size: math.min(width * 0.5, 500),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.02),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const MetricCard({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.015),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? const Color(0xFFB8C2CC) : AppColors.onSurfaceVariant,
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> dataPoints;
  final Animation<double> progress;
  final Color color;

  SparklinePainter(this.dataPoints, this.progress, this.color) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (dataPoints.isEmpty) return;

    final double stepX = size.width / (dataPoints.length - 1);
    final double maxVal = dataPoints.reduce(math.max);
    final double minVal = dataPoints.reduce(math.min);
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final double progressVal = progress.value;
    final int limit = (dataPoints.length * progressVal).ceil();

    for (int i = 0; i < limit; i++) {
      final double x = i * stepX;
      final double y = size.height - 4 - 
          ((dataPoints[i] - minVal) / range) * (size.height - 8);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Subtle glow overlay under the line
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) => true;
}

class AnimatedSparkline extends StatefulWidget {
  final Color color;
  const AnimatedSparkline({super.key, required this.color});

  @override
  State<AnimatedSparkline> createState() => _AnimatedSparklineState();
}

class _AnimatedSparklineState extends State<AnimatedSparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<double> _points = [15, 30, 20, 45, 25, 55, 35, 65, 50, 80, 60, 90];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 38),
      painter: SparklinePainter(_points, _controller, widget.color),
    );
  }
}

class SleekTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const SleekTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<SleekTextField> createState() => _SleekTextFieldState();
}

class _SleekTextFieldState extends State<SleekTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty) ...[
          Text(
            widget.labelText,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isDark ? const Color(0xFFB8C2CC) : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.onSurfaceVariant,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : Colors.black26,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: _isFocused ? AppColors.secondary : AppColors.outline,
                size: 20,
              ),
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: isDark 
                  ? const Color(0xFF141D26)
                  : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark 
                      ? const Color(0xFF334050)
                      : AppColors.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TactileButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget child;

  const TactileButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.child,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF39C12),
                Color(0xFFE67E22),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF39C12).withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}

class BlinkingDot extends StatefulWidget {
  const BlinkingDot({super.key});

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
