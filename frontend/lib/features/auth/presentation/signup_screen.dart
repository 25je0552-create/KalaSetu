import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/services/auth_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
              Text(
                ref.tr('signup'),
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'कलासेतु समुदाय से जुड़ें और अपनी शिल्प यात्रा शुरू करें',
                style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              // Name Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'पूरा नाम (Full Name)',
                    border: InputBorder.none,
                    labelStyle: TextStyle(color: AppColors.outline),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Phone Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'मोबाइल नंबर (+91 Phone)',
                    border: InputBorder.none,
                    labelStyle: TextStyle(color: AppColors.outline),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TerracottaButton(
                label: 'आगे बढ़ें • Continue',
                isLoading: _isLoading,
                onPressed: () {
                  context.push('/otp-verify', extra: '+91${_phoneController.text.trim()}');
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('पहले से खाता है? लॉगिन करें (Sign In)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
