import 'package:flutter/foundation.dart';
import '../../data/models/intruder_photo_model.dart';
import '../../services/security/intruder_detection_service.dart';

/// Provider for intruder detection state
class IntruderProvider with ChangeNotifier {
  final IntruderDetectionService _intruderService = IntruderDetectionService();

  List<IntruderPhotoModel> _intruderPhotos = [];
  bool _isLoading = false;
  bool _isEnabled = true;
  int _photoThreshold = 3;

  List<IntruderPhotoModel> get intruderPhotos => _intruderPhotos;
  bool get isLoading => _isLoading;
  bool get isEnabled => _isEnabled;
  int get photoThreshold => _photoThreshold;

  /// Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _intruderService.initialize();
      _isEnabled = _intruderService.isEnabled;
      _photoThreshold = _intruderService.photoThreshold;
      await loadIntruderPhotos();
    } catch (e) {
      debugPrint('Error initializing intruder provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all intruder photos
  Future<void> loadIntruderPhotos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _intruderPhotos = await _intruderService.getAllIntruderPhotos();
    } catch (e) {
      debugPrint('Error loading intruder photos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle failed unlock attempt
  Future<IntruderPhotoModel?> handleFailedAttempt({
    required String appPackageName,
    required String appName,
    required int failedAttemptCount,
    required String attemptType,
  }) async {
    final photo = await _intruderService.handleFailedAttempt(
      appPackageName: appPackageName,
      appName: appName,
      failedAttemptCount: failedAttemptCount,
      attemptType: attemptType,
    );

    if (photo != null) {
      _intruderPhotos.insert(0, photo);
      notifyListeners();
    }

    return photo;
  }

  /// Delete intruder photo
  Future<bool> deletePhoto(String photoId) async {
    final success = await _intruderService.deleteIntruderPhoto(photoId);
    if (success) {
      _intruderPhotos.removeWhere((photo) => photo.id == photoId);
      notifyListeners();
    }
    return success;
  }

  /// Clear all intruder photos
  Future<bool> clearAllPhotos() async {
    final success = await _intruderService.clearAllIntruderPhotos();
    if (success) {
      _intruderPhotos.clear();
      notifyListeners();
    }
    return success;
  }

  /// Enable/disable intruder detection
  Future<void> setEnabled(bool enabled) async {
    await _intruderService.setEnabled(enabled);
    _isEnabled = enabled;
    notifyListeners();
  }

  /// Set photo threshold
  Future<void> setPhotoThreshold(int threshold) async {
    await _intruderService.setPhotoThreshold(threshold);
    _photoThreshold = threshold;
    notifyListeners();
  }

  int get photoCount => _intruderPhotos.length;
}
