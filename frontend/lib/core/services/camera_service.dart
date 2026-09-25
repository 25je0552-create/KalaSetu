import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isTorchOn = false;

  bool get isInitialized => _isInitialized && _controller != null && _controller!.value.isInitialized;
  CameraController? get controller => _controller;
  int get selectedCameraIndex => _selectedCameraIndex;
  int get cameraCount => _cameras.length;
  bool get hasMultipleCameras => _cameras.length > 1;
  bool get isTorchOn => _isTorchOn;

  bool get hasTorchSupport {
    if (!isInitialized || _controller == null || _cameras.isEmpty) return false;
    final currentCamera = _cameras[_selectedCameraIndex];
    // Front-facing cameras typically do not support a hardware torch
    if (currentCamera.lensDirection == CameraLensDirection.front) return false;
    return true;
  }

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
    if (_cameras.isEmpty || cameraIndex >= _cameras.length) return;

    final camera = _cameras[cameraIndex];
    final newController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await newController.initialize();
      _controller = newController;
      _isInitialized = true;
    } catch (e) {
      debugPrint('[CameraService] Controller init error: $e');
      _isInitialized = false;
      try {
        await newController.dispose();
      } catch (_) {}
      rethrow;
    }
  }

  Future<bool> switchCamera() async {
    if (_cameras.length < 2) {
      debugPrint('[CameraService] Single-camera device; cannot switch');
      return false;
    }

    // Turn off torch before switching cameras
    if (_isTorchOn) {
      try {
        await _controller?.setFlashMode(FlashMode.off);
      } catch (_) {}
      _isTorchOn = false;
    }

    final prevIndex = _selectedCameraIndex;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;

    // Cleanly stop and release old controller
    final oldController = _controller;
    _controller = null;
    _isInitialized = false;

    if (oldController != null) {
      try {
        await oldController.dispose();
      } catch (e) {
        debugPrint('[CameraService] Dispose error during camera switch: $e');
      }
    }

    try {
      await _setupController(nextIndex);
      _selectedCameraIndex = nextIndex;
      return true;
    } catch (e) {
      debugPrint('[CameraService] Switch to camera $nextIndex failed, falling back: $e');
      // Graceful fallback to previous camera
      try {
        await _setupController(prevIndex);
        _selectedCameraIndex = prevIndex;
      } catch (fallbackError) {
        debugPrint('[CameraService] Fallback to camera $prevIndex failed: $fallbackError');
      }
      return false;
    }
  }

  Future<bool> toggleTorch() async {
    if (!hasTorchSupport || !isInitialized || _controller == null) return false;
    try {
      if (_isTorchOn) {
        await _controller!.setFlashMode(FlashMode.off);
        _isTorchOn = false;
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
        _isTorchOn = true;
      }
      return true;
    } catch (e) {
      debugPrint('[CameraService] toggleTorch error: $e');
      _isTorchOn = false;
      return false;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (!isInitialized || _controller == null) return;
    try {
      if (_isTorchOn && mode != FlashMode.torch) {
        _isTorchOn = false;
      }
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
    _isTorchOn = false;
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
