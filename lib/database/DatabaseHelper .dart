import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('todo_tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        completed INTEGER NOT NULL DEFAULT 0,
        dueDate TEXT,
        reminder INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ADD TASK
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', task);
  }

  // GET ALL TASKS
  // Future<List<Map<String, dynamic>>> getTasks() async {
  //   final db = await database;
  //   return await db.query('tasks', orderBy: 'id DESC');
  // }
  // FETCH / READ DATA FROM DATABASE
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'tasks',
      orderBy: 'id DESC',
    );

    debugPrint('Fetched records: $result');

    return result;
  }

  // UPDATE TASK
  Future<int> updateTask(int id, Map<String, dynamic> task) async {
    final db = await database;

    return await db.update('tasks', task, where: 'id = ?', whereArgs: [id]);
  }

  // DELETE TASK
  Future<int> deleteTask(int id) async {
    final db = await database;

    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // CLOSE DATABASE
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
