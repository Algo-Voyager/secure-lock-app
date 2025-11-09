import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/utils/debug_logger.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/permissions_provider.dart';
import '../../providers/app_lock_provider.dart';
import '../../../core/services/native_service.dart';

class DebugMonitorScreen extends StatefulWidget {
  const DebugMonitorScreen({super.key});

  @override
  State<DebugMonitorScreen> createState() => _DebugMonitorScreenState();
}

class _DebugMonitorScreenState extends State<DebugMonitorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;
  bool _autoRefresh = true;
  String _currentApp = 'Unknown';
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startAutoRefresh();
    _checkStatus();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_autoRefresh && mounted) {
        _checkStatus();
      }
    });
  }

  Future<void> _checkStatus() async {
    try {
      final nativeService = NativeService();
      final isRunning = await nativeService.isServiceRunning();
      final currentApp = await nativeService.getCurrentApp();

      if (mounted) {
        setState(() {
          _isServiceRunning = isRunning;
          _currentApp = currentApp ?? 'Unknown';
        });
      }

      DebugLogger().log(
        'Status Check - Service: $isRunning, Current App: $_currentApp',
        level: LogLevel.debug,
        tag: 'Monitor',
      );
    } catch (e) {
      DebugLogger().log(
        'Error checking status: $e',
        level: LogLevel.error,
        tag: 'Monitor',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Monitor'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: Icon(_autoRefresh ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() => _autoRefresh = !_autoRefresh);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkStatus,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.greenAccent,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Status'),
            Tab(icon: Icon(Icons.list), text: 'Logs'),
            Tab(icon: Icon(Icons.settings), text: 'Actions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusTab(),
          _buildLogsTab(),
          _buildActionsTab(),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('System Status'),
            const SizedBox(height: 12),

            // Service Status
            _buildStatusCard(
              'Foreground Service',
              _isServiceRunning,
              icon: Icons.play_circle,
              subtitle: _isServiceRunning ? 'Running' : 'Stopped',
            ),
            const SizedBox(height: 12),

            // Current App
            _buildInfoCard(
              'Current Foreground App',
              _currentApp,
              icon: Icons.phone_android,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),

            // Permissions Status
            _buildSectionHeader('Permissions'),
            const SizedBox(height: 12),
            Consumer<PermissionsProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    _buildStatusCard(
                      'Usage Stats',
                      provider.hasUsageStatsPermission,
                      icon: Icons.bar_chart,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusCard(
                      'Overlay Permission',
                      provider.hasOverlayPermission,
                      icon: Icons.layers,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusCard(
                      'Accessibility Service',
                      provider.isAccessibilityServiceEnabled,
                      icon: Icons.accessibility_new,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Locked Apps
            _buildSectionHeader('Locked Apps'),
            const SizedBox(height: 12),
            Consumer<AppLockProvider>(
              builder: (context, provider, child) {
                return _buildInfoCard(
                  'Total Locked Apps',
                  '${provider.lockedAppsCount}',
                  icon: Icons.lock,
                  color: Colors.orange,
                  subtitle: provider.lockedApps.isEmpty
                      ? 'No apps locked'
                      : provider.lockedApps.map((a) => a.appName).join(', '),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsTab() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Log controls
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[900],
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Real-time Logs',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    DebugLogger().clear();
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          // Logs list
          Expanded(
            child: ListenableBuilder(
              listenable: DebugLogger(),
              builder: (context, child) {
                final logs = DebugLogger().logs;

                if (logs.isEmpty) {
                  return Center(
                    child: Text(
                      'No logs yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _buildLogEntry(log);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Service Control'),
            const SizedBox(height: 12),

            _buildActionButton(
              'Start Foreground Service',
              Icons.play_circle,
              Colors.green,
              () async {
                DebugLogger().log('Manually starting foreground service...', tag: 'Action');
                final nativeService = NativeService();
                final started = await nativeService.startForegroundService();
                DebugLogger().log(
                  'Service start result: $started',
                  level: started ? LogLevel.success : LogLevel.error,
                  tag: 'Action',
                );
                await _checkStatus();
              },
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              'Stop Foreground Service',
              Icons.stop_circle,
              Colors.red,
              () async {
                DebugLogger().log('Stopping foreground service...', tag: 'Action');
                final nativeService = NativeService();
                await nativeService.stopForegroundService();
                DebugLogger().log('Service stopped', level: LogLevel.success, tag: 'Action');
                await _checkStatus();
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Permissions'),
            const SizedBox(height: 12),

            _buildActionButton(
              'Open Accessibility Settings',
              Icons.accessibility_new,
              Colors.blue,
              () async {
                DebugLogger().log('Opening accessibility settings...', tag: 'Action');
                final provider = context.read<PermissionsProvider>();
                await provider.openAccessibilitySettings();
              },
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              'Request Usage Stats',
              Icons.bar_chart,
              Colors.purple,
              () async {
                DebugLogger().log('Requesting usage stats permission...', tag: 'Action');
                final provider = context.read<PermissionsProvider>();
                await provider.requestUsageStatsPermission();
              },
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              'Request Overlay Permission',
              Icons.layers,
              Colors.orange,
              () async {
                DebugLogger().log('Requesting overlay permission...', tag: 'Action');
                final provider = context.read<PermissionsProvider>();
                await provider.requestOverlayPermission();
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Testing'),
            const SizedBox(height: 12),

            _buildActionButton(
              'Check All Permissions',
              Icons.security,
              Colors.cyan,
              () async {
                DebugLogger().log('Checking all permissions...', tag: 'Test');
                final provider = context.read<PermissionsProvider>();
                await provider.checkAllPermissions();

                DebugLogger().log(
                  'Usage Stats: ${provider.hasUsageStatsPermission}',
                  level: provider.hasUsageStatsPermission ? LogLevel.success : LogLevel.error,
                  tag: 'Test',
                );
                DebugLogger().log(
                  'Overlay: ${provider.hasOverlayPermission}',
                  level: provider.hasOverlayPermission ? LogLevel.success : LogLevel.error,
                  tag: 'Test',
                );
                DebugLogger().log(
                  'Accessibility: ${provider.isAccessibilityServiceEnabled}',
                  level: provider.isAccessibilityServiceEnabled ? LogLevel.success : LogLevel.error,
                  tag: 'Test',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.greenAccent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatusCard(String title, bool isActive, {IconData? icon, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isActive ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? Colors.green : Colors.red,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {IconData? icon, Color? color, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color ?? Colors.blue, width: 2),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color ?? Colors.blue, size: 32),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(LogEntry log) {
    Color color;
    switch (log.level) {
      case LogLevel.debug:
        color = Colors.grey;
        break;
      case LogLevel.info:
        color = Colors.blue;
        break;
      case LogLevel.warning:
        color = Colors.orange;
        break;
      case LogLevel.error:
        color = Colors.red;
        break;
      case LogLevel.success:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.formattedTime,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          if (log.tag != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.tag!,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              log.message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
