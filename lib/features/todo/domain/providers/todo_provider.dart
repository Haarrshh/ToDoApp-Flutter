import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exceptions.dart';
import '../../../../core/utils/connectivity_helper.dart';
import '../../data/models/todo_model.dart';
import '../../data/repositories/todo_repository.dart';

class TodoProvider with ChangeNotifier {
  TodoProvider({TodoRepository? repository})
      : _repo = repository ?? TodoRepository();

  final TodoRepository _repo;
  List<TodoModel> _todos = [];
  bool _loading = false;
  String? _error;
  StreamSubscription<bool>? _connectivitySub;

  List<TodoModel> get todos => List.unmodifiable(_todos);
  bool get loading => _loading;
  String? get error => _error;
  bool get isOnline => ConnectivityHelper.isOnline;

  Future<void> init() async {
    _connectivitySub = ConnectivityHelper.onConnectivityChanged.listen((online) {
      if (online) sync();
      notifyListeners();
    });
    await load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _todos = await _repo.getTodos();
      if (ConnectivityHelper.isOnline && _todos.isEmpty) {
        try {
          await _repo.loadFromApiAndSave();
          _todos = await _repo.getTodos();
        } catch (_) {
          // API may be unavailable (e.g. 403); keep empty list, use offline
        }
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sync() async {
    if (!ConnectivityHelper.isOnline) return;
    _error = null;
    try {
      await _repo.sync();
      _todos = await _repo.getTodos();
      notifyListeners();
    } catch (_) {
      
      notifyListeners();
    }
  }

  Future<void> addTodo(String title) async {
    _error = null;
    try {
      final created = await _repo.addTodo(title);
      _todos = [created, ..._todos];
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> toggleComplete(TodoModel todo) async {
    _error = null;
    try {
      final updated = await _repo.updateTodo(
        todo.copyWith(completed: !todo.completed),
      );
      _todos = _todos
          .map((t) => t.id == updated.id ? updated : t)
          .toList(growable: false);
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> updateTodo(TodoModel todo, String title) async {
    _error = null;
    try {
      final updated = await _repo.updateTodo(
        todo.copyWith(title: title),
      );
      _todos = _todos
          .map((t) => t.id == updated.id ? updated : t)
          .toList(growable: false);
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(TodoModel todo) async {
    _error = null;
    try {
      await _repo.deleteTodo(todo.id);
      _todos = _todos.where((t) => t.id != todo.id).toList(growable: false);
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
