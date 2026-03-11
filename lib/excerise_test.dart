import 'dart:convert';
import 'database/database_helper.dart';

Future<void> main() async {
  final db = await DatabaseHelper.instance.database;

  final schema = await db.rawQuery("PRAGMA table_info(Exercise);");

  print("\n===== EXERCISE TABLE SCHEMA =====");
  for (final column in schema) {
    print(
      "${column['name']} | type=${column['type']} | pk=${column['pk']}",
    );
  }

  final rows = await db.query("Exercise");

  print("\n===== CURRENT EXERCISES =====");
  print("Total rows: ${rows.length}\n");

  for (final row in rows) {
    final jsonString = row["Reference_Pose_Json"] as String;
    final decoded = jsonDecode(jsonString);

    print("Exercise ID: ${row["Exercise_id"]}");
    print("Name: ${row["Exercise_Name"]}");
    print("Description: ${row["Description"]}");
    print("Frame Count: ${(decoded["frames"] as List).length}");
    print("--------------------------------");
  }
}