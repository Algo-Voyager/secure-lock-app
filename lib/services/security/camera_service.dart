import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/// Service for capturing intruder photos silently
class CameraService {
  final Logger _logger = Logger();
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  /// Initialize the camera service
  Future<bool> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _logger.w('No cameras available on device');
        return false;
      }

      // Use front camera for intruder detection
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false, // Silent capture
      );

      await _controller!.initialize();
      _isInitialized = true;
      _logger.i('Camera service initialized successfully');
      return true;
    } catch (e) {
      _logger.e('Error initializing camera', error: e);
      return false;
    }
  }

  /// Capture photo silently (no shutter sound)
  Future<String?> captureIntruderPhoto() async {
    if (!_isInitialized || _controller == null) {
      _logger.w('Camera not initialized, attempting to initialize...');
      final initialized = await initialize();
      if (!initialized) {
        return null;
      }
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final intruderDir = Directory('${directory.path}/intruder_photos');
      if (!await intruderDir.exists()) {
        await intruderDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${intruderDir.path}/intruder_$timestamp.jpg';

      final image = await _controller!.takePicture();
      await File(image.path).copy(filePath);
      await File(image.path).delete(); // Clean up temp file

      _logger.i('Intruder photo captured: $filePath');
      return filePath;
    } catch (e) {
      _logger.e('Error capturing intruder photo', error: e);
      return null;
    }
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    try {
      await _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _logger.i('Camera service disposed');
    } catch (e) {
      _logger.e('Error disposing camera', error: e);
    }
  }

  bool get isInitialized => _isInitialized;
}
