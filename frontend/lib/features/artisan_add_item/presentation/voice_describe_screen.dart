import 'dart:io';
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
  bool _isPaused = false;
  bool _isDone = false;
  bool _isRecordingActive = false;
  final int _seconds = 24;
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
      final hasPerm = await _audioRecorder.hasPermission();
      if (!hasPerm) {
        if (mounted) {
          setState(() {
            _isPaused = false;
            _isDone = false;
            _isRecordingActive = false;
          });
        }
        return;
      }

      final tempDir = Directory.systemTemp.path;
      final filePath = '$tempDir/craft_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
      _isRecordingActive = true;
      if (mounted) {
        setState(() {
          _isPaused = false;
          _isDone = false;
        });
      }
    } catch (e) {
      debugPrint('[VoiceDescribe] Recording start exception: $e');
      _isRecordingActive = false;
      if (mounted) {
        setState(() {
          _isPaused = false;
          _isDone = false;
        });
      }
    }
  }

  Future<void> _togglePause() async {
    try {
      if (_isPaused) {
        if (_isRecordingActive && await _audioRecorder.isRecording()) {
          await _audioRecorder.resume();
        }
        if (mounted) setState(() => _isPaused = false);
      } else {
        if (_isRecordingActive && await _audioRecorder.isRecording()) {
          await _audioRecorder.pause();
        }
        if (mounted) setState(() => _isPaused = true);
      }
    } catch (e) {
      debugPrint('[VoiceDescribe] Pause toggle exception: $e');
      if (mounted) setState(() => _isPaused = !_isPaused);
    }
  }

  Future<void> _finishRecording() async {
    if (mounted) setState(() => _isDone = true);
    String? path;
    try {
      if (_isRecordingActive && await _audioRecorder.isRecording()) {
        path = await _audioRecorder.stop();
      }
    } catch (e) {
      debugPrint('[VoiceDescribe] Stop recording exception: $e');
    }
    _isRecordingActive = false;

    ref.read(addItemWizardProvider.notifier).setAudio(path ?? 'audio_sample.m4a');
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      context.push('/artisan/add-item/ai-review');
    }
  }

  @override
  void dispose() {
    _waveAnim.dispose();
    try {
      _audioRecorder.dispose();
    } catch (e) {
      debugPrint('[VoiceDescribe] Audio recorder dispose exception: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);

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
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    ref.tr('header_voice_subtitle'),
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  const LanguageTogglePill(),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/artisan/profile'),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.person_outline, color: AppColors.primary, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.record_voice_over, size: 14, color: AppColors.onSecondaryFixed),
                    const SizedBox(width: 4),
                    Text(
                      ref.tr('voice_scribe_badge'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSecondaryFixed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ref.tr('voice_scribe_title'),
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ref.tr('voice_scribe_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // Central Recording Stage Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
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
                                _isPaused ? ref.tr('paused_status') : ref.tr('listening_status'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
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
                              Row(
                                children: [
                                  const Icon(Icons.edit_note, size: 16, color: AppColors.tertiary),
                                  const SizedBox(width: 4),
                                  Text(
                                    ref.tr('live_scribe').toUpperCase(),
                                    style: const TextStyle(
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
                                child: Text(
                                  ref.tr('dialect_tag'),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ref.tr('transcription_sample'),
                            style: const TextStyle(
                              fontFamily: 'Literata',
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: [
                              Chip(
                                label: Text(ref.tr('tag_saree'), style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: AppColors.surfaceContainerHigh,
                              ),
                              Chip(
                                label: Text(ref.tr('tag_natural_dyes'), style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: AppColors.surfaceContainerHigh,
                              ),
                              Chip(
                                label: Text(ref.tr('tag_maheshwar'), style: const TextStyle(fontSize: 11)),
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
                        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ref.tr('photo_attached'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text(ref.tr('photo_attached_desc'), style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
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
                      final isHindi = ref.read(localeProvider) == AppLocale.hindi;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isHindi ? 'पुनः रिकॉर्डिंग शुरू' : 'Recording restarted')),
                      );
                    },
                    icon: const Icon(Icons.refresh, color: AppColors.tertiary),
                    label: Text(
                      ref.tr('re_record'),
                      style: const TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: _togglePause,
                    icon: Icon(_isPaused ? Icons.play_circle : Icons.pause_circle, color: AppColors.onSurfaceVariant),
                    label: Text(
                      _isPaused ? ref.tr('resume_btn') : ref.tr('pause_btn'),
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Done Primary Action
              TerracottaButton(
                label: _isDone ? ref.tr('saved_btn') : ref.tr('done_btn'),
                icon: Icons.check_circle,
                onPressed: _finishRecording,
              ),
              const SizedBox(height: 8),
              Text(
                ref.tr('done_hint'),
                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
