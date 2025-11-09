import 'package:logger/logger.dart' as log_pkg;

/// Global logger instance
/// Can be configured based on build mode
final logger = log_pkg.Logger(
  printer: log_pkg.PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

/// Production logger (less verbose)
final productionLogger = log_pkg.Logger(
  printer: log_pkg.SimplePrinter(),
  level: log_pkg.Level.warning,
);
