import 'package:sqflite/sqflite.dart';

import '../schemas/user_schema.dart';
import '../schemas/exercise_schema.dart';
import '../schemas/reference_frame_schema.dart';
import '../schemas/session_schema.dart';
import '../schemas/session_frame_schema.dart';
import '../schemas/session_performance_metrics_schema.dart';

Future<void> createTables(Database db) async {
  await db.execute(createUserTable);
  await db.execute(createExerciseTable);
  await db.execute(createReferenceFrameTable);
  await db.execute(createSessionTable);
  await db.execute(createSessionFrameTable);
  await db.execute(createSessionPerformanceMetricsTable);
}