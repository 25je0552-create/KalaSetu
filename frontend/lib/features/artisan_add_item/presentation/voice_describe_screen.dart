import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import 'add_item_wizard_controller.dart';

class VoiceDescribeScreen extends ConsumerStatefulWidget {
  const VoiceDescribeScreen({super.key});

  @override
  ConsumerState<VoiceDescribeScreen> createState() => _VoiceDescribeScreenState();
}

class _VoiceDescribeScreenState extends ConsumerState<VoiceDescribeScreen> with SingleTickerProviderStateMixin {
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isPaused = false;
  int _seconds = 24;
  late AnimationController _waveAnim;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _waveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _startRecording();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(), path: '');
        setState(() => _isRecording = true);
      }
    } catch (_) {
      setState(() => _isRecording = true);
    }
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _audioRecorder.resume();
      setState(() => _isPaused = false);
    } else {
      await _audioRecorder.pause();
      setState(() => _isPaused = true);
    }
  }

  Future<void> _finishRecording() async {
    final path = await _audioRecorder.stop();
    ref.read(addItemWizardProvider.notifier).setAudio(path ?? 'audio_sample.m4a');
    if (mounted) {
      context.push('/artisan/add-item/ai-review');
    }
  }

  @override
  void dispose() {
    _waveAnim.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(addItemWizardProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'बोलकर जोड़ें • Voice Add',
          style: TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageTogglePill(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge & Prompt Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.record_voice_over, size: 14, color: AppColors.onSecondaryFixed),
                    SizedBox(width: 4),
                    Text(
                      'आवाज से विवरण • Voice Scribe',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSecondaryFixed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'बोलिए, हम लिख लेंगे',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'स्वाभाविक रूप से बोलें, हम खरीदारों के लिए आपकी कहानी तैयार करेंगे',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // Central Recording Stage Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isPaused ? AppColors.secondary : AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isPaused ? 'रुका हुआ (Paused)' : 'सुन रहे हैं... (Listening...)',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mic, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                '00:$_seconds',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Clay Waveform
                    SizedBox(
                      height: 70,
                      child: AnimatedBuilder(
                        animation: _waveAnim,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(24, (i) {
                              final height = _isPaused
                                  ? 12.0
                                  : (15.0 + 40.0 * (((i + _waveAnim.value * 10) % 7) / 7.0));
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: 4,
                                height: height,
                                decoration: BoxDecoration(
                                  color: i % 2 == 0 ? AppColors.primary : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Transcription Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.edit_note, size: 16, color: AppColors.tertiary),
                                  SizedBox(width: 4),
                                  Text(
                                    'सीधा श्रुतलेख • LIVE SCRIBE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.tertiary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryFixed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'हिंदी (महेश्वर)',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '“मैं महेश्वर में पारंपरिक हाथ की बनी चंदेरी और सूती साड़ियाँ बनाता हूँ। इसमें प्राकृतिक नील और हल्दी के रंगों का प्रयोग किया गया है...”',
                            style: TextStyle(
                              fontFamily: 'Literata',
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Wrap(
                            spacing: 6,
                            children: [
                              Chip(
                                label: Text('साड़ी (Saree)', style: TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: AppColors.surfaceContainerHigh,
                              ),
                              Chip(
                                label: Text('प्राकृतिक रंग (Natural Dyes)', style: TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: AppColors.surfaceContainerHigh,
                              ),
                              Chip(
                                label: Text('महेश्वर (Maheshwar)', style: TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: AppColors.surfaceContainerHigh,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Attached Photo Thumbnail
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.image, color: AppColors.outline),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('तस्वीर जोड़ी गई (Photo Attached)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('महेश्वरी हैंडलूम टेक्सटाइल #04', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cached, size: 20, color: AppColors.primary),
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pause / Re-record buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _startRecording();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पुनः रिकॉर्डिंग शुरू')));
                    },
                    icon: const Icon(Icons.refresh, color: AppColors.tertiary),
                    label: const Text('फिर से बोलें (Re-record)', style: TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: _togglePause,
                    icon: Icon(_isPaused ? Icons.play_circle : Icons.pause_circle, color: AppColors.onSurfaceVariant),
                    label: Text(_isPaused ? 'जारी रखें' : 'रोकें', style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Done Primary Action
              TerracottaButton(
                label: 'पूरा हुआ • Done',
                icon: Icons.check_circle,
                onPressed: _finishRecording,
              ),
              const SizedBox(height: 8),
              const Text(
                'अपनी डिजिटल उत्पाद कथा बनाने के लिए "पूरा हुआ" पर टैप करें',
                style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
