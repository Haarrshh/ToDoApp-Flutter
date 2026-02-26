import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  ConnectivityHelper._();

  static final _connectivity = Connectivity();
  static final _controller = StreamController<bool>.broadcast();
  static bool _lastValue = true;

  static Stream<bool> get onConnectivityChanged => _controller.stream;
  static bool get isOnline => _lastValue;

  static Future<void> init() async {
    _lastValue = await check();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      _lastValue = await check();
      _controller.add(_lastValue);
    });
  }

  static Future<bool> check() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return true;
    }
    return false;
  }

  static void dispose() {
    _controller.close();
  }
}
