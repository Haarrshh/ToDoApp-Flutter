import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/error/app_exceptions.dart';
import 'core/error/crash_notifier.dart';
import 'core/error/global_error_handler.dart';
import 'core/security/device_security.dart';
import 'core/utils/connectivity_helper.dart';
import 'features/crash/crash_screen.dart';
import 'features/security/security_block_screen.dart';
import 'features/todo/domain/providers/todo_provider.dart';

void main() {
  setupGlobalErrorHandling();

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await ConnectivityHelper.init();

    bool isSecure = true;
    try {
      await DeviceSecurity.ensureSecure();
    } on SecurityException {
      isSecure = false;
    }

    if (!isSecure) {
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SecurityBlockScreen(),
        ),
      );
      return;
    }

    runApp(const AppRoot());
  }, (error, stack) {
    CrashNotifier.instance.report(error, stack);
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
  });
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  CrashReport? _crash;
  StreamSubscription<CrashReport>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = CrashNotifier.instance.onCrash.listen((report) {
      if (mounted) setState(() => _crash = report);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _clearCrash() {
    setState(() => _crash = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_crash != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CrashScreen(
          message: _crash!.error.toString(),
          onRefresh: _clearCrash,
        ),
      );
    }
    return ChangeNotifierProvider<TodoProvider>(
      create: (_) => TodoProvider()..init(),
      child: const App(),
    );
  }
}
