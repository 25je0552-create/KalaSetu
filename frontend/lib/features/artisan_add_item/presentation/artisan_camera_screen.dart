import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/widgets/clay_widgets.dart';
import 'add_item_wizard_controller.dart';

class ArtisanCameraScreen extends ConsumerStatefulWidget {
  const ArtisanCameraScreen({super.key});

  @override
  ConsumerState<ArtisanCameraScreen> createState() => _ArtisanCameraScreenState();
}

class _ArtisanCameraScreenState extends ConsumerState<ArtisanCameraScreen> {
  final CameraService _cameraService = CameraService();
  bool _isInit = false;
  bool _isCapturing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final granted = await _cameraService.requestPermissions();
    if (granted) {
      await _cameraService.initialize();
      if (mounted) setState(() => _isInit = true);
    }
  }

  Future<void> _onShutterPressed() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      XFile? photo;
      if (_cameraService.isInitialized) {
        photo = await _cameraService.takePhoto();
      }

      // If in simulator or camera not available, use a realistic sample craft photo
      final photoPath = photo?.path ?? 'sample_kulhad_craft.jpg';
      ref.read(addItemWizardProvider.notifier).setPhoto(photoPath);

      if (mounted) {
        context.push('/artisan/add-item/photo-review');
      }
    } catch (e) {
      debugPrint('[Camera] Capture error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        ref.read(addItemWizardProvider.notifier).setPhoto(picked.path);
        if (mounted) {
          context.push('/artisan/add-item/photo-review');
        }
      }
    } catch (e) {
      debugPrint('[Camera] Gallery pick error: $e');
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.asset(AppConstants.logoPath, fit: BoxFit.cover),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // 1. Framing Status Banner
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.center_focus_strong, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'सामान को बीच में रखें (Center craft)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'अच्छी रोशनी (Good light)',
                      style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Viewfinder Frame Overlay (4:5 Aspect Ratio)
              Expanded(
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x15000000), blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Live camera preview or simulator fallback
                          _cameraService.isInitialized
                              ? CameraPreview(_cameraService.controller!)
                              : Image.network(
                                  'https://images.unsplash.com/photo-1615865417491-9941019fbc00?auto=format&fit=crop&w=800&q=80',
                                  fit: BoxFit.cover,
                                ),

                          // Subtle clay gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.25),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.35),
                                ],
                              ),
                            ),
                          ),

                          // Top Controls (Flash toggle, craft mode, switch camera)
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Flash button
                                GestureDetector(
                                  onTap: () => _cameraService.toggleFlash(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.flash_off, size: 16, color: AppColors.secondary),
                                        SizedBox(width: 4),
                                        Text('बंद', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Mode badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'हस्तशिल्प मोड',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                // Switch camera
                                GestureDetector(
                                  onTap: () => _cameraService.switchCamera(),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.85),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.flip_camera_ios, size: 18, color: AppColors.onSurface),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Center Ochre Alignment Frame & Crosshairs
                          Center(
                            child: SizedBox(
                              width: 200,
                              height: 240,
                              child: Stack(
                                children: [
                                  // Top-left bracket
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: AppColors.secondaryContainer, width: 3),
                                          left: BorderSide(color: AppColors.secondaryContainer, width: 3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Top-right bracket
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: AppColors.secondaryContainer, width: 3),
                                          right: BorderSide(color: AppColors.secondaryContainer, width: 3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Bottom-left bracket
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: AppColors.secondaryContainer, width: 3),
                                          left: BorderSide(color: AppColors.secondaryContainer, width: 3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Bottom-right bracket
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: AppColors.secondaryContainer, width: 3),
                                          right: BorderSide(color: AppColors.secondaryContainer, width: 3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Center focus dot
                                  const Center(
                                    child: Icon(Icons.add, size: 28, color: AppColors.secondaryFixed),
                                  ),
                                  // Balanced level tag
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.horizontal_rule, size: 14, color: AppColors.secondary),
                                          SizedBox(width: 4),
                                          Text('संतुलित (Balanced)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom Lighting Tip Pill
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.wb_sunny, size: 14, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text('दीया या खिड़की के पास रखें', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Camera Controls (Gallery, Shutter Button, Audio Help)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gallery Picker
                    GestureDetector(
                      onTap: _pickFromGallery,
                      child: Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(height: 4),
                          const Text('गैलरी (Gallery)', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),

                    // Stamped Terracotta Shutter Button (80px)
                    GestureDetector(
                      onTap: _onShutterPressed,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 3),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Color(0x339D3E14), blurRadius: 10, offset: Offset(0, 4)),
                            ],
                          ),
                          child: _isCapturing
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.photo_camera, size: 36, color: Colors.white),
                                ),
                        ),
                      ),
                    ),

                    // Audio Help button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('कैमरा निर्देश: "सामान के चारों ओर समान रोशनी रखें..."')),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.volume_up_outlined, color: AppColors.secondary, size: 26),
                          ),
                          const SizedBox(height: 4),
                          const Text('मदद (Help)', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
