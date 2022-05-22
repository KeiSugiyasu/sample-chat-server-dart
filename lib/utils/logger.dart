import 'package:logger/logger.dart';

class _CustomeLogFilter extends LogFilter {
  final Level level;

  _CustomeLogFilter(this.level);

  @override
  void init() {}

  @override
  void destroy() {}

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= level.index;
  }
}

final logger = Logger(filter: _CustomeLogFilter(Level.verbose));
