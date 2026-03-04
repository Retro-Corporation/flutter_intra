const String createExerciseTable = '''
CREATE TABLE Exercises (
  Exercise_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Creator_User_ID INTEGER NOT NULL,
  Exercise_Name TEXT NOT NULL,
  Description TEXT,
  Validation_Rules TEXT,
  Created_At DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';