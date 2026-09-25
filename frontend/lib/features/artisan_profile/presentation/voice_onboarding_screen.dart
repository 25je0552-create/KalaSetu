import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';

class VoiceOnboardingScreen extends ConsumerStatefulWidget {
  const VoiceOnboardingScreen({super.key});

  @override
  ConsumerState<VoiceOnboardingScreen> createState() => _VoiceOnboardingScreenState();
}

class _VoiceOnboardingScreenState extends ConsumerState<VoiceOnboardingScreen> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  bool _isRecorded = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    debugPrint('[VoiceOnboardingScreen] Initialized');
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startListening() {
    debugPrint('[VoiceOnboardingScreen] Mic pressed down -> listening started');
    setState(() {
      _isListening = true;
      _isRecorded = false;
    });
  }

  void _stopListening() {
    debugPrint('[VoiceOnboardingScreen] Mic released -> listening stopped, voice recorded');
    setState(() {
      _isListening = false;
      _isRecorded = true;
    });
    final isHindi = ref.read(localeProvider) == AppLocale.hindi;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHindi
              ? 'आवाज़ दर्ज की गई! "रमेश प्रजापति, गोरखपुर, माटी शिल्पी"'
              : 'Voice recorded! "Ramesh Prajapati, Gorakhpur, Terracotta Artisan"',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildRippleRing(double offset) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        if (!_isListening) {
          return Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
          );
        }
        final progress = (_animController.value + offset) % 1.0;
        final size = 100.0 + (progress * 130.0);
        final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.55;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: opacity),
              width: 2.0,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final isHindi = currentLocale == AppLocale.hindi;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.9),
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4), width: 0.8)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                    onPressed: () {
                      debugPrint('[VoiceOnboardingScreen] Back button tapped');
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/artisan/home');
                      }
                    },
                  ),
                  Text(
                    ref.tr('voice_onboarding_badge'),
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  const LanguageTogglePill(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.record_voice_over, size: 16, color: AppColors.onSecondaryFixed),
                    const SizedBox(width: 6),
                    Text(
                      ref.tr('voice_onboarding_badge'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSecondaryFixed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ref.tr('voice_onboarding_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ref.tr('voice_onboarding_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 48),

              // Fixed-dimension ripple hub so widgets below remain 100% static
              SizedBox(
                width: 240,
                height: 240,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRippleRing(0.0),
                      _buildRippleRing(0.33),
                      _buildRippleRing(0.66),
                      // Big Action Seal Button
                      GestureDetector(
                        onTapDown: (_) => _startListening(),
                        onTapUp: (_) => _stopListening(),
                        onTapCancel: () => _stopListening(),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _isListening ? AppColors.primaryContainer : AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Color(0x339D3E14), blurRadius: 16, offset: Offset(0, 6)),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isListening
                                    ? Icons.graphic_eq
                                    : (_isRecorded ? Icons.check_circle : Icons.mic),
                                size: 42,
                                color: Colors.white,
                              ),
                              Text(
                                ref.tr('speak_action').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isListening ? AppColors.secondaryFixed : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isListening ? AppColors.secondary : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isListening
                          ? (isHindi ? 'सुन रहे हैं... (Listening...)' : 'Listening...')
                          : (_isRecorded ? ref.tr('voice_recorded') : ref.tr('hold_to_speak')),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isListening ? ref.tr('release_hint') : ref.tr('hold_hint'),
                style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              const SizedBox(height: 36),

              // Artisan workshop snippet
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.hearing, color: AppColors.secondary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.tr('artisan_help_title'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            ref.tr('artisan_help_desc'),
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fallback text form link
              TextButton(
                onPressed: () {
                  debugPrint('[VoiceOnboardingScreen] Prefer typing pressed -> navigating to /artisan/story-input');
                  context.push('/artisan/story-input');
                },
                child: Column(
                  children: [
                    Text(
                      ref.tr('prefer_typing'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tertiary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ref.tr('fill_standard_form'),
                      style: const TextStyle(fontSize: 11, color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
