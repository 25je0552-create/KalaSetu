import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/studio_api_service.dart';
import '../core/theme/app_theme.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  File? _selectedImage;
  Uint8List? _transformedImageBytes;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndTransformImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = File(pickedFile.path);
      _isLoading = true;
      _transformedImageBytes = null;
    });

    // Call backend API (united.py Module 1 pipeline)
    final processedBytes = await StudioApiService.transformStudioImage(_selectedImage!);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _transformedImageBytes = processedBytes;
    });

    if (processedBytes == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Studio server not reachable or processing failed. Showing original photo.",
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'KalaSetu - AI Virtual Studio',
          style: TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surfaceContainerHigh,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _pickAndTransformImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text(
                  'Select Craft Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) ...[
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 10),
              const Text(
                "Enhancing contrast & generating studio backdrop...",
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
            ],
            if (_transformedImageBytes != null) ...[
              const Text(
                "Enhanced Result (united.py Pipeline):",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.memory(
                    _transformedImageBytes!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ] else if (_selectedImage != null && !_isLoading) ...[
              const Text(
                "Original Image:",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(_selectedImage!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
