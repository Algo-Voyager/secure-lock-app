import 'package:flutter/material.dart';
import '../../../core/utils/debug_logger.dart';

/// Standalone logs screen that displays real-time debug logs
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastLogCount = 0;

  @override
  void initState() {
    super.initState();
    // Add initial log when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (DebugLogger().logs.isEmpty) {
        DebugLogger().log('Logs screen initialized', level: LogLevel.info, tag: 'Logs');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.brightness == Brightness.dark ? Colors.black : Colors.grey[50],
      child: Column(
        children: [
          // Log controls
          Container(
            padding: const EdgeInsets.all(12),
            color: theme.brightness == Brightness.dark 
                ? Colors.grey[900] 
                : Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Real-time Logs',
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark
                          ? Colors.greenAccent
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    DebugLogger().clear();
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
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
                final currentLogCount = logs.length;

                // Auto-scroll to top when new logs arrive
                if (currentLogCount > _lastLogCount && _scrollController.hasClients) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
                _lastLogCount = currentLogCount;

                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No logs yet',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Logs will appear here as the app runs',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false, // Show newest first (they're already in reverse order)
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _buildLogEntry(context, log, theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(BuildContext context, LogEntry log, ThemeData theme) {
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

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.formattedTime,
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[700],
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
                color: isDark ? color : color.withOpacity(0.9),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

