import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import 'add_item_wizard_controller.dart';

class PhotoReviewScreen extends ConsumerStatefulWidget {
  const PhotoReviewScreen({super.key});

  @override
  ConsumerState<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends ConsumerState<PhotoReviewScreen> {
  bool _showAfter = true; // Toggle between Before & After AI Studio Backdrop
  double? _imageAspectRatio;
  String? _lastResolvedPath;

  @override
  void initState() {
    super.initState();
    final currentPath = ref.read(addItemWizardProvider).capturedPhotoPath;
    debugPrint('[PhotoReviewScreen] Initialized. photoPath: $currentPath');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveImageAspectRatio();
    });
  }

  void _resolveImageAspectRatio() {
    final photoPath = ref.read(addItemWizardProvider).capturedPhotoPath;
    if (_lastResolvedPath == photoPath && _imageAspectRatio != null) return;
    _lastResolvedPath = photoPath;

    final ImageProvider provider = (photoPath != null && File(photoPath).existsSync())
        ? FileImage(File(photoPath))
        : const NetworkImage('https://images.unsplash.com/photo-1615865417491-9941019fbc00?auto=format&fit=crop&w=800&q=80') as ImageProvider;

    provider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          if (mounted) {
            final width = info.image.width.toDouble();
            final height = info.image.height.toDouble();
            if (width > 0 && height > 0) {
              final ratio = width / height;
              debugPrint('[PhotoReviewScreen] Aspect ratio resolved: $ratio (dimensions: ${width}x${height})');
              setState(() {
                _imageAspectRatio = ratio;
              });
            }
          }
        },
        onError: (dynamic error, StackTrace? _) {
          debugPrint('[PhotoReview] Image aspect ratio resolve error: $error');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(addItemWizardProvider);
    final photoPath = wizardState.capturedPhotoPath;
    if (photoPath != _lastResolvedPath) {
      _resolveImageAspectRatio();
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          ref.tr('photo_review_title'),
          style: const TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageTogglePill(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Toggle: Before (Raw Photo) vs After (AI Studio Backdrop)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          debugPrint('[PhotoReviewScreen] Switched to Original Photo view');
                          setState(() => _showAfter = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_showAfter ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              ref.tr('original_photo_tab'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: !_showAfter ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          debugPrint('[PhotoReviewScreen] Switched to AI Studio Backdrop view');
                          setState(() => _showAfter = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _showAfter ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              ref.tr('ai_studio_tab'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _showAfter ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Visual Display Stage: dynamically sized to the photo's natural aspect ratio, opens cropper on tap
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      final effectivePath = photoPath ??
                          'https://images.unsplash.com/photo-1615865417491-9941019fbc00?auto=format&fit=crop&w=800&q=80';
                      debugPrint('[PhotoReviewScreen] Tapped photo to crop -> opening /artisan/add-item/crop');
                      final result = await context.push<String>('/artisan/add-item/crop', extra: effectivePath);
                      debugPrint('[PhotoReviewScreen] Returned from cropper: result=$result');
                      if (result != null && mounted) {
                        _resolveImageAspectRatio();
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: _imageAspectRatio ?? (4 / 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _showAfter ? AppColors.surfaceBright : Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: _showAfter ? const Color(0x1F785440) : Colors.black26,
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              photoPath != null && File(photoPath).existsSync()
                                  ? Image.file(
                                      File(photoPath),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      'https://images.unsplash.com/photo-1615865417491-9941019fbc00?auto=format&fit=crop&w=800&q=80',
                                      fit: BoxFit.cover,
                                    ),
                              // AI Studio subtle depth vignette
                              if (_showAfter)
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: Alignment.center,
                                      radius: 0.9,
                                      colors: [
                                        Colors.transparent,
                                        Colors.brown.withValues(alpha: 0.10),
                                      ],
                                    ),
                                  ),
                                ),
                              // Harmonized craft detection bounding box overlay aligned dynamically to photo ratio
                              Center(
                                child: FractionallySizedBox(
                                  widthFactor: 0.78,
                                  heightFactor: 0.78,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _showAfter ? AppColors.primary : AppColors.secondaryContainer,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              // Dedicated Crop & Adjust Prompt Badge
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.crop, size: 13, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        ref.watch(localeProvider) == AppLocale.hindi ? 'क्रॉप करें' : 'Tap to Crop',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
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
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Studio Treatment Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ref.tr('studio_treatment_note'),
                        style: const TextStyle(fontSize: 12, height: 1.3, color: AppColors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Retake vs Confirm buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      onPressed: () {
                        debugPrint('[PhotoReviewScreen] Retake button tapped -> popping to camera');
                        context.pop();
                      },
                      child: Text(ref.tr('retake_btn')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TerracottaButton(
                      label: ref.tr('next_btn'),
                      height: 54,
                      icon: Icons.arrow_forward,
                      onPressed: () {
                        debugPrint('[PhotoReviewScreen] Next button tapped -> navigating to voice describe');
                        context.push('/artisan/add-item/voice-describe');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
