import 'package:flutter/material.dart';

import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'features/todo/presentation/screens/todo_list_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: EnvConfig.instance.appTitle,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const TodoListScreen(),
    );
  }
}
