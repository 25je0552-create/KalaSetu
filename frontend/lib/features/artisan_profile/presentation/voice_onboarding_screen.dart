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
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() => _isListening = true);
  }

  void _stopListening() {
    setState(() => _isListening = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('स्वर परिचय दर्ज हुआ! "रमेश प्रजापति, गोरखपुर, माटी शिल्पी"'),
        duration: Duration(seconds: 2),
      ),
    );
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.record_voice_over, size: 16, color: AppColors.onSecondaryFixed),
                    SizedBox(width: 6),
                    Text(
                      'स्वर परिचय • Voice Onboarding',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSecondaryFixed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'मुझे अपने बारे में बताएं',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'आपका नाम, आपका शिल्प, और आपका गाँव',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant),
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
                              color: AppColors.secondaryContainer.withOpacity(_isListening ? 0.6 : 0.2),
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
                              color: AppColors.secondary.withOpacity(_isListening ? 0.7 : 0.3),
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
                              _isListening ? Icons.graphic_eq : Icons.mic,
                              size: 44,
                              color: Colors.white,
                            ),
                            const Text(
                              'बोलें',
                              style: TextStyle(
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
                      _isListening ? 'सुन रहे हैं... (Listening...)' : 'दबाकर बोलें (Hold to Speak)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'माइक्रोफ़ोन को दबाए रखें और बोलना शुरू करें',
                style: TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              const SizedBox(height: 36),

              // Artisan workshop snippet
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(12),
                child: const Row(
                  children: [
                    Icon(Icons.hearing, color: AppColors.secondary, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'कारीगर सहायता • खुल कर बोलें',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'अपनी भाषा व क्षेत्रीय बोली में बेझिझक बोलें',
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
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
                    const SnackBar(content: Text('मैन्युअल फ़ॉर्म खोला जा रहा है...')),
                  );
                },
                child: const Column(
                  children: [
                    Text(
                      'लिखकर भरना चाहते हैं? (Type instead)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tertiary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'साधारण फ़ॉर्म भरें',
                      style: TextStyle(fontSize: 11, color: AppColors.outline),
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
