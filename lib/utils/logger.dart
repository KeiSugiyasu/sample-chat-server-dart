import 'package:logger/logger.dart';

/// Custom log filter
class _CustomeLogFilter extends LogFilter {
  final Level level;

  _CustomeLogFilter(this.level);

  @override
  void init() {}

  @override
  void destroy() {}

  /// Decide whether print the log or not depending on the log's level and the setting.
  ///
  /// The default implementation of [shouldLog] is very optimized to Flutter application, so it needes to be overridden.
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= level.index;
  }
}

/// Logger.
final logger = Logger(filter: _CustomeLogFilter(Level.verbose));
