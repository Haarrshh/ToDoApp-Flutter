import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../global_components/widgets/empty_state.dart';
import '../../../../global_components/widgets/error_view.dart';
import '../../../../global_components/widgets/loading_indicator.dart';
import '../../domain/providers/todo_provider.dart';
import '../widgets/animated_todo_item.dart';
import 'todo_edit_screen.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  static const _duration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do'),
        actions: [
          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              if (!provider.isOnline) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.sync),
                onPressed: provider.loading ? null : () => provider.sync(),
              );
            },
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          return AnimatedSwitcher(
            duration: _duration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            ),
            child: _buildBody(context, provider),
          );
        },
      ),
      floatingActionButton: _AnimatedFab(
        onPressed: () => _openAdd(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TodoProvider provider) {
    if (provider.error != null) {
      return ErrorView(
        key: const ValueKey('error'),
        message: provider.error!,
        onRetry: () {
          provider.clearError();
          provider.load();
        },
      );
    }
    if (provider.loading && provider.todos.isEmpty) {
      return const LoadingIndicator(key: ValueKey('loading'));
    }
    if (provider.todos.isEmpty) {
      return EmptyState(
        key: const ValueKey('empty'),
        message: 'No tasks yet.\nTap + to add one.',
        icon: Icons.task_alt,
      );
    }
    return Column(
      key: const ValueKey('list'),
      children: [
        if (!provider.isOnline) _buildOfflineBanner(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: Responsive.horizontalPadding(context),
            ),
            itemCount: provider.todos.length,
            itemBuilder: (context, index) {
              final todo = provider.todos[index];
              return AnimatedTodoItem(
                key: ValueKey(todo.id),
                todo: todo,
                index: index,
                total: provider.todos.length,
                onToggle: provider.toggleComplete,
                onTap: (t) => _openEdit(context, t),
                onDelete: provider.deleteTodo,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.orange.shade100,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 18, color: Colors.orange.shade900),
              const SizedBox(width: 8),
              Text(
                'Offline – changes will sync when online',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    Navigator.of(context).push(_editRoute(const TodoEditScreen()));
  }

  void _openEdit(BuildContext context, dynamic todo) {
    Navigator.of(context).push(_editRoute(TodoEditScreen(todo: todo)));
  }

  PageRoute<void> _editRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = Curves.easeOutCubic;
        final curved = CurvedAnimation(parent: animation, curve: curve);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}

class _AnimatedFab extends StatefulWidget {
  const _AnimatedFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<_AnimatedFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton(
        onPressed: () {
          _controller.forward().then((_) => _controller.reverse());
          widget.onPressed();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
