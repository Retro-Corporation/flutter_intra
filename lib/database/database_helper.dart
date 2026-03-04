import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'migrations/create_tables.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'exercise_app.db';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // So bascially this is what creates the tables
  Future<void> _onCreate(Database db, int version) async {
    await createTables(db); 
  }

  Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // All the updates that occurs later within the schemas goes here
  }
}