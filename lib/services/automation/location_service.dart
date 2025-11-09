import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import '../../data/models/automation_rule_model.dart';

/// Service for location-based automation
class LocationService {
  final Logger _logger = Logger();
  Position? _lastKnownPosition;
  DateTime? _lastPositionUpdate;

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      _logger.e('Error requesting location permission', error: e);
      return false;
    }
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      if (!await hasLocationPermission()) {
        _logger.w('Location permission not granted');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      _lastKnownPosition = position;
      _lastPositionUpdate = DateTime.now();

      return position;
    } catch (e) {
      _logger.e('Error getting current location', error: e);
      return _lastKnownPosition; // Return last known position as fallback
    }
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Check if current location is within a rule's radius
  Future<bool> isInLocation(AutomationRuleModel rule) async {
    if (rule.latitude == null || rule.longitude == null || rule.radiusMeters == null) {
      return false;
    }

    try {
      final currentPosition = await getCurrentLocation();
      if (currentPosition == null) {
        return false;
      }

      final distance = calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        rule.latitude!,
        rule.longitude!,
      );

      final isInside = distance <= rule.radiusMeters!;
      _logger.d('Distance to ${rule.locationName}: ${distance.toStringAsFixed(0)}m (${isInside ? "INSIDE" : "OUTSIDE"})');

      return isInside;
    } catch (e) {
      _logger.e('Error checking location', error: e);
      return false;
    }
  }

  /// Start monitoring location changes
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100, // Update every 100 meters
      ),
    );
  }

  Position? get lastKnownPosition => _lastKnownPosition;
}
