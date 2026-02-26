import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import '../error/app_exceptions.dart';

class AppDatabase {
  AppDatabase._();
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = join(dir.path, AppConstants.dbName);
      return openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
      );
    } catch (e) {
      throw StorageException('Failed to open database', originalError: e);
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.todoTable} (
        id INTEGER PRIMARY KEY,
        remote_id INTEGER,
        title TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        user_id INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        sync_pending INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_todos_sync ON ${AppConstants.todoTable}(sync_pending);');
  }

  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
