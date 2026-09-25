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
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _isRecorded = false;
    });
  }

  void _stopListening() {
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

              // Concentric Wave Hub & Large Mic Button
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ripple
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final scale = _isListening ? 1.0 + (_animController.value * 0.3) : 1.0;
                        return Container(
                          width: 220 * scale,
                          height: 220 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondaryContainer.withValues(alpha: _isListening ? 0.6 : 0.2),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    // Mid ripple
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final scale = _isListening ? 1.0 + (_animController.value * 0.15) : 1.0;
                        return Container(
                          width: 170 * scale,
                          height: 170 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: _isListening ? 0.7 : 0.3),
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHindi ? 'साधारण फ़ॉर्म खोला जा रहा है...' : 'Opening standard form...',
                      ),
                    ),
                  );
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
