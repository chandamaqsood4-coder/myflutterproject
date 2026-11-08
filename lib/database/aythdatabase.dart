import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AuthDatabaseHelper {
  static final AuthDatabaseHelper instance = AuthDatabaseHelper._init();

  static Database? _database;

  AuthDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('thinkcodes_auth.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // REGISTER USER
  Future<int> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;

    return db.insert('users', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });
  }

  // CHECK EMAIL
  Future<bool> emailExists(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email.trim()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // LOGIN USER
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim(), password],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return result.first;
  }

  // CLOSE DATABASE
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
