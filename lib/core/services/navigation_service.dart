import 'package:flutter/widgets.dart';
import '../../core/constants/app_constants.dart';

/// Simple navigation service to allow routing without BuildContext
class NavigationService {
  NavigationService._internal();
  static final NavigationService instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isLockScreenVisible = false;
  String? _pendingPackageToLock;

  /// Show the lock screen route safely from anywhere
  Future<void> showLockScreen({String? packageName}) async {
    // Avoid stacking multiple lock screens
    if (_isLockScreenVisible) return;

    final nav = navigatorKey.currentState;
    if (nav == null) {
      // Defer until a frame when navigator is ready
      _pendingPackageToLock = packageName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pendingPackageToLock != null && navigatorKey.currentState != null && !_isLockScreenVisible) {
          final pkg = _pendingPackageToLock;
          _pendingPackageToLock = null;
          _pushLockScreenInternal(pkg);
        }
      });
      return;
    }

    await _pushLockScreenInternal(packageName);
  }

  Future<void> _pushLockScreenInternal(String? packageName) async {
    _isLockScreenVisible = true;
    try {
      // We pass packageName as an argument in case the screen wants to use it later
      await navigatorKey.currentState!
          .pushNamed(AppConstants.routeLockScreen, arguments: {'packageName': packageName});
    } finally {
      _isLockScreenVisible = false;
    }
  }
}

