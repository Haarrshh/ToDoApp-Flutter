import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/todo_model.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final TodoModel todo;
  final ValueChanged<TodoModel> onToggle;
  final ValueChanged<TodoModel> onTap;
  final ValueChanged<TodoModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.onError, size: 28),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDelete(todo),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => onTap(todo),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Checkbox(
                  value: todo.completed,
                  onChanged: (_) => onToggle(todo),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.completed ? TextDecoration.lineThrough : null,
                      color: todo.completed ? AppColors.outline : AppColors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => onTap(todo),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
