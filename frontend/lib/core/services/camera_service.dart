import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized && _controller != null && _controller!.value.isInitialized;
  CameraController? get controller => _controller;
  int get selectedCameraIndex => _selectedCameraIndex;

  Future<bool> requestPermissions() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('[CameraService] No physical camera found (simulator mode)');
        return;
      }

      await _setupController(_selectedCameraIndex);
    } catch (e) {
      debugPrint('[CameraService] Initialization error: $e');
    }
  }

  Future<void> _setupController(int cameraIndex) async {
    if (_cameras.isEmpty) return;

    final camera = _cameras[cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('[CameraService] Controller init error: $e');
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    await _setupController(_selectedCameraIndex);
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (!isInitialized || _controller == null) return;
    try {
      await _controller!.setFlashMode(mode);
    } catch (e) {
      debugPrint('[CameraService] setFlashMode error: $e');
    }
  }

  Future<void> toggleFlash() async {
    if (!isInitialized || _controller == null) return;
    final current = _controller!.value.flashMode;
    final next = current == FlashMode.off ? FlashMode.always : FlashMode.off;
    await setFlashMode(next);
  }

  Future<XFile?> takePhoto({FlashMode? flashMode}) async {
    if (!isInitialized || _controller == null) return null;
    try {
      if (flashMode != null) {
        await _controller!.setFlashMode(flashMode);
        // Ensure hardware sensor auto-exposure and flash pre-capture settle
        if (flashMode == FlashMode.always || flashMode == FlashMode.auto) {
          await Future.delayed(const Duration(milliseconds: 120));
        }
      }
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint('[CameraService] takePicture error: $e');
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }
}
