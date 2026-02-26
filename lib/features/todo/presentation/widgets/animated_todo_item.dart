import 'package:flutter/material.dart';

import '../../data/models/todo_model.dart';
import 'todo_tile.dart';

class AnimatedTodoItem extends StatefulWidget {
  const AnimatedTodoItem({
    super.key,
    required this.todo,
    required this.index,
    required this.total,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final TodoModel todo;
  final int index;
  final int total;
  final ValueChanged<TodoModel> onToggle;
  final ValueChanged<TodoModel> onTap;
  final ValueChanged<TodoModel> onDelete;

  @override
  State<AnimatedTodoItem> createState() => _AnimatedTodoItemState();
}

class _AnimatedTodoItemState extends State<AnimatedTodoItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    final start = widget.total > 0 ? widget.index / widget.total : 0.0;
    final end = widget.total > 0 ? (widget.index + 1) / widget.total : 1.0;
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));
    Future.microtask(() => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: TodoTile(
          todo: widget.todo,
          onToggle: widget.onToggle,
          onTap: widget.onTap,
          onDelete: widget.onDelete,
        ),
      ),
    );
  }
}
