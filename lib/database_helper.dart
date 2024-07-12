// lib/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'test.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    var dbClient = await db;
    int res = await dbClient.insert("users", user);
    return res;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query("users");
    return res;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    var dbClient = await db;
    int res = await dbClient.update("users", user, where: "id = ?", whereArgs: [user['id']]);
    return res;
  }

  Future<int> deleteUser(int id) async {
    var dbClient = await db;
    int res = await dbClient.delete("users", where: 'id = ?', whereArgs: [id]);
    return res;
  }
}
