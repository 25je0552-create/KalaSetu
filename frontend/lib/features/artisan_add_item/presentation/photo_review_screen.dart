import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import 'add_item_wizard_controller.dart';

class PhotoReviewScreen extends ConsumerStatefulWidget {
  const PhotoReviewScreen({super.key});

  @override
  ConsumerState<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends ConsumerState<PhotoReviewScreen> {
  bool _showAfter = true; // Toggle between Before & After AI Studio Backdrop

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(addItemWizardProvider);
    final photoPath = wizardState.capturedPhotoPath;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'फोटो समीक्षा • Photo Review',
          style: TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
                        onTap: () => setState(() => _showAfter = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_showAfter ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'मूल फोटो (Original)',
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
                        onTap: () => setState(() => _showAfter = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _showAfter ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'स्टूडियो पृष्ठभूमि (AI Studio)',
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

              // Visual Display Stage
              Expanded(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      // TODO: replace with real bg-removal model output (U²-Net/rembg via backend)
                      color: _showAfter ? AppColors.surfaceBright : Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: _showAfter ? const Color(0x1F785440) : Colors.black26,
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: _showAfter ? const EdgeInsets.all(24) : EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: photoPath != null && File(photoPath).existsSync()
                          ? Image.file(File(photoPath), fit: BoxFit.contain)
                          : Image.network(
                              'https://images.unsplash.com/photo-1615865417491-9941019fbc00?auto=format&fit=crop&w=800&q=80',
                              fit: BoxFit.contain,
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
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'पृष्ठभूमि स्वतः साफ की गई है ताकि खरीदार केवल आपकी कारीगरी पर ध्यान दें।',
                        style: TextStyle(fontSize: 12, height: 1.3, color: AppColors.onSurface),
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
                      onPressed: () => context.pop(),
                      child: const Text('दोबारा खींचें (Retake)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TerracottaButton(
                      label: 'आगे बढ़ें • Next',
                      height: 54,
                      icon: Icons.arrow_forward,
                      onPressed: () => context.push('/artisan/add-item/voice-describe'),
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
