import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'schema.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'exercise_app.db';
  static const int dbVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;

    if (kIsWeb) {
      // Web uses IndexedDB internally
      path = dbName;
    } else {
      final databasesPath = await getDatabasesPath();
      path = join(databasesPath, dbName);
    }

    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(createUserTable);
    await db.execute(createExerciseTable);
    await db.execute(createSystemMetricsTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // future schema migrations
  }
}