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

class _ArtisanCameraScreenState extends ConsumerState<ArtisanCameraScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isCapturing = false;
  bool _showFlashOverlay = false;
  int _flashState = 0; // 0: off, 1: on, 2: auto
  bool _isVoiceRecording = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraService.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final granted = await _cameraService.requestPermissions();
    if (granted) {
      await _cameraService.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _onShutterPressed() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
      _showFlashOverlay = true;
    });

    // Tactile screen flash effect
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _showFlashOverlay = false);
    });

    try {
      XFile? photo;
      if (_cameraService.isInitialized) {
        final mode = _flashState == 1
            ? FlashMode.always
            : (_flashState == 2 ? FlashMode.auto : FlashMode.off);
        photo = await _cameraService.takePhoto(flashMode: mode);
      }

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

  void _cycleFlash() async {
    final nextState = (_flashState + 1) % 3;
    setState(() {
      _flashState = nextState;
    });
    final mode = nextState == 1
        ? FlashMode.always
        : (nextState == 2 ? FlashMode.auto : FlashMode.off);
    await _cameraService.setFlashMode(mode);
  }

  void _toggleVoiceNote() {
    setState(() {
      _isVoiceRecording = !_isVoiceRecording;
    });
    final isHindi = ref.read(localeProvider) == AppLocale.hindi;
    if (_isVoiceRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi
                ? 'आवाज सुन रहे हैं... सामान का विवरण बोलें'
                : 'Listening... Describe the craft item',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      context.push('/artisan/add-item/voice-describe');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);

    final flashLabels = [
      ref.tr('flash_off'),
      ref.tr('flash_on'),
      ref.tr('flash_auto'),
    ];
    final flashIcons = [
      Icons.flash_off,
      Icons.flash_on,
      Icons.flash_auto,
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4), width: 0.5)),
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
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // 1. Framing Status Banner
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.center_focus_strong, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ref.tr('center_craft_hint'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                          ),
                        ),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ref.tr('good_light'),
                          style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Viewfinder Frame Overlay (dynamic aspect ratio & dark surface to prevent yellow rendering bug)
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: isPortrait ? (4 / 5) : (5 / 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x15000000), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Live camera preview scaled correctly to prevent aspect ratio / orientation glitch
                              if (_cameraService.isInitialized && _cameraService.controller != null)
                                Center(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    clipBehavior: Clip.hardEdge,
                                    child: SizedBox(
                                      width: _cameraService.controller!.value.previewSize != null
                                          ? (isPortrait
                                              ? _cameraService.controller!.value.previewSize!.height
                                              : _cameraService.controller!.value.previewSize!.width)
                                          : (isPortrait ? 720 : 1280),
                                      height: _cameraService.controller!.value.previewSize != null
                                          ? (isPortrait
                                              ? _cameraService.controller!.value.previewSize!.width
                                              : _cameraService.controller!.value.previewSize!.height)
                                          : (isPortrait ? 1280 : 720),
                                      child: CameraPreview(_cameraService.controller!),
                                    ),
                                  ),
                                )
                              else
                                Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCF1WoBZgqM24_q4yeNmcBo3uSKRiyFqnM4Y6Boj3WRImT4D4NVb0pLlvRtwxJh5tA9MMrlR8KpPwWeX0XAyw1FZf2x9OK-janmeVVotPAzcLg8ktVbC_l5hWEW6qX3hn5RQZ7uoItJV5oSVX9UpQHpe2kDPO155oVM1WlWv8iBZnv-kei-dg_m1AQ-KnHPfgVJ6vzKJh0Hq9zrb8yHu7DM7mOUg8ETBLVlASneowvaM4DtyMod3BOM',
                                  fit: BoxFit.cover,
                                ),

                          // Subtle clay gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.25),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.35),
                                ],
                              ),
                            ),
                          ),

                          // Flash Effect Animation Overlay
                          if (_showFlashOverlay)
                            Container(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),

                          // Top Controls inside Viewfinder
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Flash button
                                GestureDetector(
                                  onTap: _cycleFlash,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(flashIcons[_flashState], size: 16, color: AppColors.secondary),
                                        const SizedBox(width: 4),
                                        Text(flashLabels[_flashState], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Craft Mode Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    ref.tr('craft_mode'),
                                    style: const TextStyle(
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
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.88),
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
                              width: 210,
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
                                  // Center focus crosshairs
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
                                        color: Colors.white.withValues(alpha: 0.88),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.horizontal_rule, size: 14, color: AppColors.secondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            ref.tr('balanced'),
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
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
                                  color: Colors.white.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.wb_sunny, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      ref.tr('lighting_tip'),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
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
              const SizedBox(height: 14),

              // 3. Camera Controls (Gallery, Shutter Button, Add by Voice)
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
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ref.tr('gallery'),
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),

                    // Stamped Terracotta Shutter Button (80px)
                    GestureDetector(
                      onTap: _onShutterPressed,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 3),
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
                                  child: Icon(Icons.photo_camera, size: 34, color: Colors.white),
                                ),
                        ),
                      ),
                    ),

                    // Add by Voice note button
                    GestureDetector(
                      onTap: _toggleVoiceNote,
                      child: Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: _isVoiceRecording ? AppColors.primary : AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                            ),
                            child: Icon(
                              _isVoiceRecording ? Icons.graphic_eq : Icons.mic,
                              color: _isVoiceRecording ? Colors.white : AppColors.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ref.tr('voice_add_btn'),
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Artisan Tip Box (कारीगर सलाह)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.onSecondaryContainer),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.tr('artisan_tip_title'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
                          ),
                          Text(
                            ref.tr('artisan_tip_desc'),
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
);
}
}
