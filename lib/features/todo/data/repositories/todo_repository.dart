import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/connectivity_helper.dart';
import '../models/todo_model.dart';

class TodoRepository {
  TodoRepository({
    ApiClient? apiClient,
  }) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<TodoModel>> getTodos() async {
    final db = await AppDatabase.database;
    final list = await db.query(
      AppConstants.todoTable,
      orderBy: 'id DESC',
    );
    return list.map((e) => TodoModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<TodoModel>> fetchFromApi() async {
    final response = await _api.get(ApiEndpoints.todos);
    final raw = response is List ? response : (response as Map)['response'];
    if (raw is! List) return [];
    return raw
        .map((e) => TodoModel.fromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> loadFromApiAndSave() async {
    if (!ConnectivityHelper.isOnline) return;
    final list = await fetchFromApi();
    final db = await AppDatabase.database;
    await db.delete(AppConstants.todoTable);
    for (final t in list) {
      await db.insert(AppConstants.todoTable, t.toJson());
    }
  }

  Future<void> syncPendingToApi() async {
    if (!ConnectivityHelper.isOnline) return;
    final db = await AppDatabase.database;
    final pending = await db.query(
      AppConstants.todoTable,
      where: 'sync_pending = ?',
      whereArgs: [1],
    );
    for (final row in pending) {
      final todo = TodoModel.fromJson(Map<String, dynamic>.from(row));
      try {
        if (todo.remoteId != null) {
          await _api.put(ApiEndpoints.todo(todo.remoteId!), body: todo.toApi());
        } else {
          final res = await _api.post(ApiEndpoints.todos, body: todo.toApi());
          await db.update(
            AppConstants.todoTable,
            {'remote_id': res['id'], 'sync_pending': 0},
            where: 'id = ?',
            whereArgs: [todo.id],
          );
        }
      } catch (_) {}
    }
  }

  Future<TodoModel> addTodo(String title, {bool completed = false}) async {
    final db = await AppDatabase.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final todo = TodoModel(
      id: now ~/ 1000,
      title: title,
      completed: completed,
      createdAt: now,
      updatedAt: now,
      syncPending: true,
    );
    await db.insert(AppConstants.todoTable, todo.toJson());
    if (ConnectivityHelper.isOnline) {
      // Fire-and-forget remote sync so UI is not blocked by network latency.
      () async {
        try {
          final res = await _api.post(ApiEndpoints.todos, body: todo.toApi());
          await db.update(
            AppConstants.todoTable,
            {'remote_id': res['id'], 'sync_pending': 0},
            where: 'id = ?',
            whereArgs: [todo.id],
          );
        } catch (_) {
          // Keep local todo; it will be synced on the next sync cycle.
        }
      }();
    }
    return todo;
  }

  Future<TodoModel?> getTodoById(int id) async {
    final db = await AppDatabase.database;
    final list = await db.query(
      AppConstants.todoTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (list.isEmpty) return null;
    return TodoModel.fromJson(Map<String, dynamic>.from(list.first));
  }

  Future<TodoModel> updateTodo(TodoModel todo) async {
    final db = await AppDatabase.database;
    final updated = todo.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncPending: true,
    );
    await db.update(
      AppConstants.todoTable,
      updated.toJson(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
    if (ConnectivityHelper.isOnline) {
      try {
        if (todo.remoteId != null) {
          await _api.put(ApiEndpoints.todo(todo.remoteId!), body: todo.toApi());
          await db.update(
            AppConstants.todoTable,
            {'sync_pending': 0},
            where: 'id = ?',
            whereArgs: [todo.id],
          );
        }
      } catch (_) {}
    }
    return updated;
  }

  Future<void> deleteTodo(int id) async {
    final todo = await getTodoById(id);
    if (todo == null) return;
    final db = await AppDatabase.database;
    await db.delete(
      AppConstants.todoTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (ConnectivityHelper.isOnline && todo.remoteId != null) {
      try {
        await _api.delete(ApiEndpoints.todo(todo.remoteId!));
      } catch (_) {}
    }
  }

  Future<void> sync() async {
    await syncPendingToApi();
    await loadFromApiAndSave();
  }
}
