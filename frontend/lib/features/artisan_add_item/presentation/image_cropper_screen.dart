import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import 'add_item_wizard_controller.dart';

enum CropAspectRatio { free, square, portrait, landscape }

class ImageCropperScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const ImageCropperScreen({
    super.key,
    required this.imagePath,
  });

  @override
  ConsumerState<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends ConsumerState<ImageCropperScreen> {
  // Normalized crop coordinates [0.0 to 1.0]
  double _left = 0.08;
  double _top = 0.08;
  double _right = 0.92;
  double _bottom = 0.92;

  CropAspectRatio _selectedRatio = CropAspectRatio.free;
  int _rotationQuarterTurns = 0;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    debugPrint('[ImageCropperScreen] Initialized with image: ${widget.imagePath}');
  }

  void _applyAspectRatio(CropAspectRatio ratio) {
    debugPrint('[ImageCropperScreen] Aspect ratio selected: $ratio');
    setState(() {
      _selectedRatio = ratio;
      final centerX = (_left + _right) / 2;
      final centerY = (_top + _bottom) / 2;
      double width = _right - _left;
      double height = _bottom - _top;

      switch (ratio) {
        case CropAspectRatio.square:
          final side = width < height ? width : height;
          _left = (centerX - side / 2).clamp(0.02, 0.98);
          _right = (centerX + side / 2).clamp(0.02, 0.98);
          _top = (centerY - side / 2).clamp(0.02, 0.98);
          _bottom = (centerY + side / 2).clamp(0.02, 0.98);
          break;
        case CropAspectRatio.portrait: // 4:5
          final targetHeight = width * 1.25;
          if (targetHeight <= 0.94) {
            _top = (centerY - targetHeight / 2).clamp(0.02, 0.98);
            _bottom = (centerY + targetHeight / 2).clamp(0.02, 0.98);
          } else {
            final targetWidth = height / 1.25;
            _left = (centerX - targetWidth / 2).clamp(0.02, 0.98);
            _right = (centerX + targetWidth / 2).clamp(0.02, 0.98);
          }
          break;
        case CropAspectRatio.landscape: // 16:9
          final targetHeight = width * (9 / 16);
          _top = (centerY - targetHeight / 2).clamp(0.02, 0.98);
          _bottom = (centerY + targetHeight / 2).clamp(0.02, 0.98);
          break;
        case CropAspectRatio.free:
          break;
      }
    });
  }

  void _resetCrop() {
    debugPrint('[ImageCropperScreen] Reset crop parameters');
    setState(() {
      _left = 0.05;
      _top = 0.05;
      _right = 0.95;
      _bottom = 0.95;
      _rotationQuarterTurns = 0;
      _selectedRatio = CropAspectRatio.free;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _confirmCrop() {
    debugPrint('[ImageCropperScreen] Crop confirmed: rect=($_left, $_top, $_right, $_bottom), rotation=$_rotationQuarterTurns');
    // Save cropped state to the wizard controller
    ref.read(addItemWizardProvider.notifier).setPhoto(widget.imagePath);

    final isHindi = ref.read(localeProvider) == AppLocale.hindi;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHindi ? 'फ़ोटो का आकार सफलतापूर्वक समायोजित किया गया' : 'Photo cropped and aligned successfully',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop(widget.imagePath);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = ref.watch(localeProvider) == AppLocale.hindi;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          tooltip: isHindi ? 'रद्द करें' : 'Cancel',
          onPressed: () {
            debugPrint('[ImageCropperScreen] Close / cancel tapped');
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          isHindi ? 'फ़ोटो क्रॉप व ज़ूम' : 'Crop & Frame Photo',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontFamily: 'Literata',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined, color: Colors.white),
            tooltip: isHindi ? 'घुमाएँ' : 'Rotate',
            onPressed: () {
              final nextTurns = (_rotationQuarterTurns + 1) % 4;
              debugPrint('[ImageCropperScreen] Rotate 90 deg clockwise. New turns: $nextTurns');
              setState(() {
                _rotationQuarterTurns = nextTurns;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Colors.white),
            tooltip: isHindi ? 'रीसेट करें' : 'Reset',
            onPressed: _resetCrop,
          ),
          TextButton(
            onPressed: _confirmCrop,
            child: Text(
              isHindi ? 'संपन्न' : 'Done',
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Hint Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white10,
              child: Row(
                children: [
                  const Icon(Icons.pinch, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isHindi
                          ? 'ज़ूम करने के लिए पिंच करें, कोनों को खींचकर क्रॉप क्षेत्र बदलें'
                          : 'Pinch to zoom image. Drag corners or inside to resize and move crop box.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Main Interactive Cropping View
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final canvasWidth = constraints.maxWidth;
                  final canvasHeight = constraints.maxHeight;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Zoomable & Pannable Base Image
                      Center(
                        child: RotatedBox(
                          quarterTurns: _rotationQuarterTurns,
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: 0.8,
                            maxScale: 4.5,
                            boundaryMargin: const EdgeInsets.all(80),
                            child: widget.imagePath.startsWith('http')
                                ? Image.network(
                                    widget.imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 64),
                                  )
                                : Image.file(
                                    File(widget.imagePath),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Image.network(
                                      'https://images.unsplash.com/photo-1615865417491-9941019fbc00?auto=format&fit=crop&w=800&q=80',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // Dark Scrim Mask outside crop rect
                      CustomPaint(
                        size: Size(canvasWidth, canvasHeight),
                        painter: _CropOverlayPainter(
                          rect: Rect.fromLTRB(
                            _left * canvasWidth,
                            _top * canvasHeight,
                            _right * canvasWidth,
                            _bottom * canvasHeight,
                          ),
                        ),
                      ),

                      // Freeform Center Pan Handle (moves entire box)
                      Positioned(
                        left: _left * canvasWidth,
                        top: _top * canvasHeight,
                        width: (_right - _left) * canvasWidth,
                        height: (_bottom - _top) * canvasHeight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanUpdate: (details) {
                            final dx = details.delta.dx / canvasWidth;
                            final dy = details.delta.dy / canvasHeight;
                            final width = _right - _left;
                            final height = _bottom - _top;

                            setState(() {
                              if (_left + dx >= 0.01 && _right + dx <= 0.99) {
                                _left += dx;
                                _right += dx;
                              }
                              if (_top + dy >= 0.01 && _bottom + dy <= 0.99) {
                                _top += dy;
                                _bottom += dy;
                              }
                            });
                          },
                        ),
                      ),

                      // Corner Handle: Top-Left
                      _buildCornerHandle(
                        left: _left * canvasWidth - 16,
                        top: _top * canvasHeight - 16,
                        onPanUpdate: (delta) {
                          setState(() {
                            final nextLeft = (_left + delta.dx / canvasWidth).clamp(0.01, _right - 0.15);
                            final nextTop = (_top + delta.dy / canvasHeight).clamp(0.01, _bottom - 0.15);
                            _left = nextLeft;
                            _top = nextTop;
                          });
                        },
                      ),

                      // Corner Handle: Top-Right
                      _buildCornerHandle(
                        left: _right * canvasWidth - 16,
                        top: _top * canvasHeight - 16,
                        onPanUpdate: (delta) {
                          setState(() {
                            final nextRight = (_right + delta.dx / canvasWidth).clamp(_left + 0.15, 0.99);
                            final nextTop = (_top + delta.dy / canvasHeight).clamp(0.01, _bottom - 0.15);
                            _right = nextRight;
                            _top = nextTop;
                          });
                        },
                      ),

                      // Corner Handle: Bottom-Left
                      _buildCornerHandle(
                        left: _left * canvasWidth - 16,
                        top: _bottom * canvasHeight - 16,
                        onPanUpdate: (delta) {
                          setState(() {
                            final nextLeft = (_left + delta.dx / canvasWidth).clamp(0.01, _right - 0.15);
                            final nextBottom = (_bottom + delta.dy / canvasHeight).clamp(_top + 0.15, 0.99);
                            _left = nextLeft;
                            _bottom = nextBottom;
                          });
                        },
                      ),

                      // Corner Handle: Bottom-Right
                      _buildCornerHandle(
                        left: _right * canvasWidth - 16,
                        top: _bottom * canvasHeight - 16,
                        onPanUpdate: (delta) {
                          setState(() {
                            final nextRight = (_right + delta.dx / canvasWidth).clamp(_left + 0.15, 0.99);
                            final nextBottom = (_bottom + delta.dy / canvasHeight).clamp(_top + 0.15, 0.99);
                            _right = nextRight;
                            _bottom = nextBottom;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Toolbar: Aspect Ratio Presets
            Container(
              color: const Color(0xFF181818),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRatioButton(
                    label: isHindi ? 'मुक्त' : 'Free',
                    icon: Icons.crop_free,
                    ratio: CropAspectRatio.free,
                  ),
                  _buildRatioButton(
                    label: '1:1',
                    icon: Icons.crop_square,
                    ratio: CropAspectRatio.square,
                  ),
                  _buildRatioButton(
                    label: '4:5',
                    icon: Icons.crop_portrait,
                    ratio: CropAspectRatio.portrait,
                  ),
                  _buildRatioButton(
                    label: '16:9',
                    icon: Icons.crop_16_9,
                    ratio: CropAspectRatio.landscape,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerHandle({
    required double left,
    required double top,
    required Function(Offset delta) onPanUpdate,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => onPanUpdate(details.delta),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatioButton({
    required String label,
    required IconData icon,
    required CropAspectRatio ratio,
  }) {
    final isSelected = _selectedRatio == ratio;
    return GestureDetector(
      onTap: () => _applyAspectRatio(ratio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect rect;

  _CropOverlayPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Semi-transparent black scrim outside crop rect
    final bgPaint = Paint()..color = const Color(0x99000000);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cropPath = Path()..addRect(rect);
    final maskPath = Path.combine(PathOperation.difference, fullPath, cropPath);
    canvas.drawPath(maskPath, bgPaint);

    // 2. White border around crop rect
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, borderPaint);

    // 3. Rule of Thirds grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final stepX = rect.width / 3;
    final stepY = rect.height / 3;

    // Vertical grid lines
    canvas.drawLine(Offset(rect.left + stepX, rect.top), Offset(rect.left + stepX, rect.bottom), gridPaint);
    canvas.drawLine(Offset(rect.left + stepX * 2, rect.top), Offset(rect.left + stepX * 2, rect.bottom), gridPaint);

    // Horizontal grid lines
    canvas.drawLine(Offset(rect.left, rect.top + stepY), Offset(rect.right, rect.top + stepY), gridPaint);
    canvas.drawLine(Offset(rect.left, rect.top + stepY * 2), Offset(rect.right, rect.top + stepY * 2), gridPaint);
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}
