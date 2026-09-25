import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _errorMessage = 'कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendOtp('+91$phone');
      if (mounted) {
        context.push('/otp-verify', extra: '+91$phone');
      }
    } catch (e) {
      setState(() => _errorMessage = 'ओटीपी भेजने में त्रुटि: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();

      // Set user session in Riverpod
      ref.read(authStateProvider.notifier).setAuthenticatedUser(
        const AppUser(
          id: 'google_user_1',
          name: 'रमेश प्रजापति',
          email: 'artisan.ramesh@gmail.com',
          role: UserRole.artisan,
        ),
      );

      if (mounted) {
        context.go('/role-select');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Google साइन-इन त्रुटि: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageTogglePill(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: ClipOval(
                    child: Image.asset(AppConstants.logoPath, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                ref.tr('login'),
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'अपने पंजीकृत मोबाइल नंबर से प्रवेश करें',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // Phone Input Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      '+91',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1.2, height: 28, color: AppColors.outlineVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: '98765 43210',
                          counterText: '',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.outline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              // Send OTP Primary Button
              TerracottaButton(
                label: ref.tr('send_otp'),
                icon: Icons.send_rounded,
                isLoading: _isLoading,
                onPressed: _handleSendOtp,
              ),
              const SizedBox(height: 24),
              // Divider "or"
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'या / OR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),
              // Official Google Branded Sign-In Button
              // Conforming strictly to Google Button Branding Guidelines: White background, official G icon, grey border
              SizedBox(
                height: 54,
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1F1F1F),
                    side: const BorderSide(color: Color(0xFF747775), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                  child: _isGoogleLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://fonts.gstatic.com/s/i/productlogos/googleg/v6/24px.svg',
                              width: 22,
                              height: 22,
                              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 28, color: Colors.blue),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              // Create account link
              Center(
                child: TextButton(
                  onPressed: () => context.push('/signup'),
                  child: const Text.rich(
                    TextSpan(
                      text: 'नया खाता बनाना है? ',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'खाता बनाएं (Sign Up)',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
