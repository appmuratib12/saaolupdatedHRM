import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'checkin_activity.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE checkin_activity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            loginTime TEXT,
            logoutTime TEXT,
            workingHours TEXT
          )
        ''');
      },
    );
  }


  Future<void> insertActivity(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('checkin_activity', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCachedActivity() async {
    final db = await database;
    return await db.query('checkin_activity');
  }

  Future<void> clearActivity() async {
    final db = await database;
    await db.delete('checkin_activity');
  }
}
