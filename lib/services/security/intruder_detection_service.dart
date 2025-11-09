import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import '../../data/models/intruder_photo_model.dart';
import '../../core/services/storage_service.dart';
import 'camera_service.dart';

/// Service for detecting and logging intruder attempts
class IntruderDetectionService {
  final Logger _logger = Logger();
  final CameraService _cameraService = CameraService();
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  bool _isEnabled = true;
  int _photoThreshold = 3; // Capture photo after 3 failed attempts

  /// Initialize the service
  Future<void> initialize() async {
    try {
      await _storageService.init();
      // Load settings
      _isEnabled = await _storageService.getBool('intruder_detection_enabled') ?? true;
      _photoThreshold = await _storageService.getInt('intruder_photo_threshold') ?? 3;
      _logger.i('Intruder detection service initialized');
    } catch (e) {
      _logger.e('Error initializing intruder detection service', error: e);
    }
  }

  /// Handle failed unlock attempt
  Future<IntruderPhotoModel?> handleFailedAttempt({
    required String appPackageName,
    required String appName,
    required int failedAttemptCount,
    required String attemptType,
  }) async {
    if (!_isEnabled) {
      _logger.d('Intruder detection is disabled');
      return null;
    }

    if (failedAttemptCount < _photoThreshold) {
      _logger.d('Failed attempts ($failedAttemptCount) below threshold ($_photoThreshold)');
      return null;
    }

    try {
      _logger.i('Capturing intruder photo for $appName after $failedAttemptCount failed attempts');

      // Capture photo
      final photoPath = await _cameraService.captureIntruderPhoto();
      if (photoPath == null) {
        _logger.w('Failed to capture intruder photo');
        return null;
      }

      // Get location (if permission granted)
      String? locationName;
      String? latitude;
      String? longitude;

      try {
        final position = await _getCurrentLocation();
        if (position != null) {
          latitude = position.latitude.toString();
          longitude = position.longitude.toString();
          locationName = await _getLocationName(position);
        }
      } catch (e) {
        _logger.w('Could not get location for intruder photo', error: e);
      }

      // Create intruder photo record
      final intruderPhoto = IntruderPhotoModel(
        id: _uuid.v4(),
        photoPath: photoPath,
        timestamp: DateTime.now(),
        appPackageName: appPackageName,
        appName: appName,
        failedAttempts: failedAttemptCount,
        location: locationName,
        latitude: latitude,
        longitude: longitude,
        attemptType: attemptType,
      );

      // Save to storage
      await _saveIntruderPhoto(intruderPhoto);

      _logger.i('Intruder photo saved successfully');
      return intruderPhoto;
    } catch (e) {
      _logger.e('Error handling failed attempt', error: e);
      return null;
    }
  }

  /// Get current GPS location
  Future<Position?> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      _logger.w('Error getting current location', error: e);
      return null;
    }
  }

  /// Get location name from coordinates
  Future<String?> _getLocationName(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
      }
    } catch (e) {
      _logger.w('Error getting location name', error: e);
    }
    return null;
  }

  /// Save intruder photo to storage
  Future<void> _saveIntruderPhoto(IntruderPhotoModel photo) async {
    try {
      final box = await _storageService.getBox<IntruderPhotoModel>('intruder_photos');
      await box.put(photo.id, photo);
    } catch (e) {
      _logger.e('Error saving intruder photo', error: e);
    }
  }

  /// Get all intruder photos
  Future<List<IntruderPhotoModel>> getAllIntruderPhotos() async {
    try {
      final box = await _storageService.getBox<IntruderPhotoModel>('intruder_photos');
      return box.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      _logger.e('Error getting intruder photos', error: e);
      return [];
    }
  }

  /// Delete intruder photo
  Future<bool> deleteIntruderPhoto(String id) async {
    try {
      final box = await _storageService.getBox<IntruderPhotoModel>('intruder_photos');
      await box.delete(id);
      return true;
    } catch (e) {
      _logger.e('Error deleting intruder photo', error: e);
      return false;
    }
  }

  /// Clear all intruder photos
  Future<bool> clearAllIntruderPhotos() async {
    try {
      final box = await _storageService.getBox<IntruderPhotoModel>('intruder_photos');
      await box.clear();
      return true;
    } catch (e) {
      _logger.e('Error clearing intruder photos', error: e);
      return false;
    }
  }

  /// Enable/disable intruder detection
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _storageService.saveBool('intruder_detection_enabled', enabled);
  }

  /// Set photo capture threshold
  Future<void> setPhotoThreshold(int threshold) async {
    _photoThreshold = threshold;
    await _storageService.saveInt('intruder_photo_threshold', threshold);
  }

  bool get isEnabled => _isEnabled;
  int get photoThreshold => _photoThreshold;
}
