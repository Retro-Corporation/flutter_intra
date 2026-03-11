import 'dart:convert';
import 'database/database_helper.dart';

Future<void> debugDatabase() async {
  final db = await DatabaseHelper.instance.database;

  print("\n========== DATABASE TABLES ==========");

  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table'"
  );

  for (final t in tables) {
    print(t['name']);
  }

  print("\n========== EXERCISE TABLE SCHEMA ==========");

  final schema = await db.rawQuery("PRAGMA table_info(Exercise)");

  for (final column in schema) {
    print(
      "${column['name']} | type=${column['type']} | pk=${column['pk']}"
    );
  }

  print("\n========== EXERCISE TABLE DATA ==========");

  final rows = await db.query("Exercise");

  print("Total rows: ${rows.length}\n");

  for (final row in rows) {
    print("Exercise ID: ${row['Exercise_id']}");
    print("Name: ${row['Exercise_Name']}");
    print("Description: ${row['Description']}");

    final jsonString = row['Reference_Pose_Json'] as String;
    final decoded = jsonDecode(jsonString);

    if (decoded is Map && decoded['frames'] != null) {
      print("Frame count: ${(decoded['frames'] as List).length}");
    }

    print("---------------------------");
  }
}