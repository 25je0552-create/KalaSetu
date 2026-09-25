import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/services/auth_service.dart';

class BuyerLoginScreen extends ConsumerStatefulWidget {
  const BuyerLoginScreen({super.key});

  @override
  ConsumerState<BuyerLoginScreen> createState() => _BuyerLoginScreenState();
}

class _BuyerLoginScreenState extends ConsumerState<BuyerLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _signInAsBuyer({String? phone}) {
    debugPrint('[BuyerLoginScreen] Authenticating as buyer: phone=${phone ?? "+91 98111 22334"} -> routing to /buyer/home');
    ref.read(authStateProvider.notifier).setAuthenticatedUser(
      AppUser(
        id: 'buyer_usr_${DateTime.now().millisecondsSinceEpoch}',
        phone: phone ?? '+91 98111 22334',
        name: ref.read(localeProvider) == AppLocale.hindi ? 'कला सेतु ग्राहक' : 'KalaSetu Buyer',
        role: UserRole.customer,
      ),
    );
    context.go('/buyer/home');
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      debugPrint('[BuyerLoginScreen] Phone validation failed for input: "$phone"');
      setState(() => _errorMessage = ref.tr('phone_error'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('[BuyerLoginScreen] Sending buyer OTP to +91$phone');
      final authService = ref.read(authServiceProvider);
      await authService.sendOtp('+91$phone');
      debugPrint('[BuyerLoginScreen] OTP sent successfully to +91$phone');
      if (mounted) {
        _signInAsBuyer(phone: '+91$phone');
      }
    } catch (e) {
      debugPrint('[BuyerLoginScreen] Buyer OTP send failed: $e');
      final isHindi = ref.read(localeProvider) == AppLocale.hindi;
      setState(() => _errorMessage = isHindi ? 'ओटीपी भेजने में त्रुटि: $e' : 'Error sending OTP: $e');
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
      debugPrint('[BuyerLoginScreen] Initiating Google Sign-In for buyer');
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();

      ref.read(authStateProvider.notifier).setAuthenticatedUser(
        const AppUser(
          id: 'buyer_google_1',
          name: 'Ananya Verma',
          email: 'ananya.buyer@gmail.com',
          role: UserRole.customer,
        ),
      );

      debugPrint('[BuyerLoginScreen] Google Sign-In succeeded -> routing to /buyer/home');
      if (mounted) {
        context.go('/buyer/home');
      }
    } catch (e) {
      debugPrint('[BuyerLoginScreen] Buyer Google Sign-In failed: $e');
      final isHindi = ref.read(localeProvider) == AppLocale.hindi;
      setState(() => _errorMessage = isHindi ? 'Google साइन-इन त्रुटि: $e' : 'Google sign-in error: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final isHindi = currentLocale == AppLocale.hindi;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageTogglePill(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo & App Name
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x149D3E14),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: ClipOval(
                        child: Image.asset(AppConstants.logoPath, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ref.tr('app_name'),
                          style: const TextStyle(
                            fontFamily: 'Literata',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isHindi ? 'खरीदार बाज़ार' : 'Buyer App',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryFixed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHindi ? 'सीधे भारतीय कारीगरों से प्रामाणिक हस्तशिल्प खरीदें' : 'Shop authentic Indian crafts directly from master artisans',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // User Role / Portal Toggle: Shopkeeper vs Buyer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.go('/login');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.storefront, size: 18, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                isHindi ? 'मैं दुकानदार हूँ' : "I'm a Shopkeeper",
                                style: const TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Color(0x20556B2F), blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag, size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              isHindi ? 'मैं खरीदार हूँ' : "I'm a Buyer",
                              style: const TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Title and Subtitle
              Text(
                isHindi ? 'खरीदार लॉगिन' : 'Buyer Sign In',
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isHindi ? 'अपने फोन नंबर या Google खाते से लॉगिन करें' : 'Sign in to explore artisan collections & track your orders',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

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
                        decoration: InputDecoration(
                          hintText: ref.tr('phone_placeholder'),
                          counterText: '',
                          border: InputBorder.none,
                          hintStyle: const TextStyle(color: AppColors.outline),
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
              const SizedBox(height: 18),

              // Send OTP Primary Button
              TerracottaButton(
                label: ref.tr('send_otp'),
                icon: Icons.send_rounded,
                isLoading: _isLoading,
                onPressed: _handleSendOtp,
              ),
              const SizedBox(height: 16),

              // Instant Continue as Buyer (Instant Guest Access)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.explore_outlined, size: 20),
                  label: Text(
                    isHindi ? 'सीधे खरीदारी शुरू करें (अतिथि)' : 'Continue as Guest Buyer',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () => _signInAsBuyer(),
                ),
              ),
              const SizedBox(height: 20),

              // Divider "or"
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      ref.tr('or_divider'),
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: 20),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.surfaceContainerLow,
                  ),
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                  child: _isGoogleLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              width: 18,
                              height: 18,
                              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24, color: AppColors.primary),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              ref.tr('continue_google'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
