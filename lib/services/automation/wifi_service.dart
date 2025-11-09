import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:logger/logger.dart';
import '../../data/models/automation_rule_model.dart';

/// Service for WiFi-based automation
class WiFiService {
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

  String? _currentSSID;
  String? _currentBSSID;

  /// Check if connected to WiFi
  Future<bool> isConnectedToWiFi() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      // connectivity_plus 5.x returns a single ConnectivityResult, not a list
      return connectivityResult == ConnectivityResult.wifi;
    } catch (e) {
      _logger.e('Error checking WiFi connection', error: e);
      return false;
    }
  }

  /// Get current WiFi SSID
  Future<String?> getCurrentSSID() async {
    try {
      if (!await isConnectedToWiFi()) {
        return null;
      }

      _currentSSID = await _networkInfo.getWifiName();

      // Remove quotes from SSID if present
      if (_currentSSID != null) {
        _currentSSID = _currentSSID!.replaceAll('"', '');
      }

      return _currentSSID;
    } catch (e) {
      _logger.e('Error getting WiFi SSID', error: e);
      return null;
    }
  }

  /// Get current WiFi BSSID (MAC address)
  Future<String?> getCurrentBSSID() async {
    try {
      if (!await isConnectedToWiFi()) {
        return null;
      }

      _currentBSSID = await _networkInfo.getWifiBSSID();
      return _currentBSSID;
    } catch (e) {
      _logger.e('Error getting WiFi BSSID', error: e);
      return null;
    }
  }

  /// Check if currently connected to a rule's WiFi network
  Future<bool> isConnectedToRuleWiFi(AutomationRuleModel rule) async {
    if (rule.wifiSSID == null && rule.wifiBSSID == null) {
      return false;
    }

    try {
      if (!await isConnectedToWiFi()) {
        return false;
      }

      // Check SSID if specified
      if (rule.wifiSSID != null) {
        final currentSSID = await getCurrentSSID();
        if (currentSSID == null || currentSSID != rule.wifiSSID) {
          return false;
        }
      }

      // Check BSSID if specified (more specific than SSID)
      if (rule.wifiBSSID != null) {
        final currentBSSID = await getCurrentBSSID();
        if (currentBSSID == null || currentBSSID != rule.wifiBSSID) {
          return false;
        }
      }

      _logger.d('Connected to rule WiFi: ${rule.wifiSSID}');
      return true;
    } catch (e) {
      _logger.e('Error checking WiFi rule', error: e);
      return false;
    }
  }

  /// Watch for WiFi connectivity changes
  Stream<ConnectivityResult> watchConnectivity() {
    return _connectivity.onConnectivityChanged;
  }

  String? get currentSSID => _currentSSID;
  String? get currentBSSID => _currentBSSID;
}
