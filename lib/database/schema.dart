

// User Table Schema
const String createUserTable = '''
CREATE TABLE IF NOT EXISTS User (
  User_id INTEGER PRIMARY KEY AUTOINCREMENT,
  User_Name TEXT NOT NULL UNIQUE,
  User_Password TEXT NOT NULL
);
''';


// Exercise Table Schema
const String createExerciseTable = '''
CREATE TABLE IF NOT EXISTS Exercise (
  Exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
  Exercise_Name TEXT NOT NULL,
  Description TEXT,
  Reference_Pose_Json TEXT NOT NULL,
  Created_AT DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

// System Metrics Table Schema
const String createSystemMetricsTable = '''
CREATE TABLE IF NOT EXISTS System_Metrics (
  Metrics_id INTEGER PRIMARY KEY AUTOINCREMENT,
  Endpoint TEXT NOT NULL,
  Latency_Ms REAL NOT NULL,
  Processing_Time_Ms REAL NOT NULL,
  Status TEXT NOT NULL,
  TimeStamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';