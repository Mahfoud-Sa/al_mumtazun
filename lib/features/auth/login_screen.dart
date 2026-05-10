import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localization/l10n.dart';
import '../../localization/locale_cubit.dart';
import '../../theme/app_colors.dart';
import 'auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _rememberDevice = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    setState(() => _loading = true);
    await context.read<AuthCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Opacity(
              opacity: 0.03,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: const SizedBox(),
            ),
          ),

          // Main Content
          Column(
            children: [
              // TopAppBar
              Container(
                height: 64,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'محل المتميزون',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              context.read<LocaleCubit>().toggleEnglishArabic(),
                          icon: const Icon(Icons.language, size: 18),
                          label: Text(
                            (context
                                            .read<LocaleCubit>()
                                            .state
                                            .locale
                                            ?.languageCode ??
                                        'en') ==
                                    'ar'
                                ? l10n.english
                                : l10n.arabic,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.help_outline,
                            color: AppColors.primary,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Login Card Area
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 440),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.security,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          Text(
                            'مرحبا بعودتك',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "يرجى ادخال البيانات الخاصة بك للدخول للنظام",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Form
                          // Email Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "اسم المستخدم او رقم الهاتف",
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: "م.ث: 771234567 او سالم احمد",
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.outline,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.secondaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'كلمة السر',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      ' نسيت كلمة السر?',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: AppColors.secondaryContainer,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.outline,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.outline,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.secondaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Remember me
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberDevice,
                                  onChanged: (val) => setState(
                                    () => _rememberDevice = val ?? false,
                                  ),
                                  activeColor: AppColors.secondaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "ذكرني ",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _onLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF39C12),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "تسجيل الدخول",
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.login, size: 20),
                                      ],
                                    ),
                            ),
                          ),

                          // Status and Links
                          const SizedBox(height: 32),
                          const Divider(color: AppColors.outlineVariant),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const BlinkingDot(),
                                  const SizedBox(width: 8),
                                  Text(
                                    'الدعم الفني',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     TextButton(
                              //       onPressed: () {},
                              //       child: Text(
                              //         'الدعم الفني',
                              //         style: theme.textTheme.labelLarge
                              //             ?.copyWith(
                              //               color: const Color(0xFF8192A7),
                              //             ),
                              //       ),
                              //     ),
                              //     // TextButton(
                              //     //   onPressed: () {},
                              //     //   child: Text(
                              //     //     'MFA Help',
                              //     //     style: theme.textTheme.labelLarge
                              //     //         ?.copyWith(
                              //     //           color: const Color(0xFF8192A7),
                              //     //         ),
                              //     //   ),
                              //     // ),
                              //   ],
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainer,
                  border: Border(
                    top: BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Text(
                      '© 2026 غير مصرح الدخول الا باستخدام الترخيص من مشرف النظام',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8691A6),
                      ),
                    ),
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     TextButton(
                    //       onPressed: () {},
                    //       child: Text(
                    //         'Privacy Policy',
                    //         style: theme.textTheme.labelLarge?.copyWith(
                    //           color: const Color(0xFF8691A6),
                    //         ),
                    //       ),
                    //     ),
                    //     TextButton(
                    //       onPressed: () {},
                    //       child: Text(
                    //         'Security Standards',
                    //         style: theme.textTheme.labelLarge?.copyWith(
                    //           color: const Color(0xFF8691A6),
                    //         ),
                    //       ),
                    //     ),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Text(
                    //         'System Status',
                    //         style: theme.textTheme.labelLarge?.copyWith(
                    //           color: const Color(0xFF8691A6),
                    //         ),
                    //       ),
                    //       const SizedBox(width: 4),
                    //       const Icon(
                    //         Icons.open_in_new,
                    //         size: 14,
                    //         color: Color(0xFF8691A6),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    //  ],
                    //  ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
