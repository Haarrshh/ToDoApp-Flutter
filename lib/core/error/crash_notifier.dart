import 'dart:async';

class CrashNotifier {
  CrashNotifier._();

  static final CrashNotifier _instance = CrashNotifier._();
  static CrashNotifier get instance => _instance;

  final _controller = StreamController<CrashReport>.broadcast();
  Stream<CrashReport> get onCrash => _controller.stream;

  void report(Object error, StackTrace stack) {
    if (!_controller.isClosed) {
      _controller.add(CrashReport(error: error, stack: stack));
    }
  }

  void dispose() {
    _controller.close();
  }
}

class CrashReport {
  CrashReport({required this.error, required this.stack});

  final Object error;
  final StackTrace stack;
}
