
// User Table Schema
const String createUserTable = '''
CREATE TABLE Users (
  User_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  User_Name TEXT NOT NULL,
  User_Password PASSWORD NOT NULL,
  Created_At DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

// Exercise Table Schema
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

// Session Table Schema
const String createSessionTable = '''
CREATE TABLE Sessions (
  Session_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  User_ID INTEGER NOT NULL,
  Exercise_ID INTEGER NOT NULL,
  Started_At DATETIME NOT NULL,
  Ended_At DATETIME,
  Is_Completed BOOLEAN DEFAULT 0,
  Rep_Count INTEGER DEFAULT 0,
  Accuracy_Score REAL DEFAULT 0,
  FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
  FOREIGN KEY (Exercise_ID) REFERENCES Exercises(Exercise_ID)
);
''';

// Session Frames Table Schema
const String createSessionFrameTable = '''
CREATE TABLE Session_Frames (
  Frame_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Session_ID INTEGER NOT NULL,
  Frame_Number INTEGER NOT NULL,
  Timestamp REAL NOT NULL,
  Pose_Json TEXT NOT NULL,
  FOREIGN KEY (Session_ID) REFERENCES Sessions(Session_ID)
);
''';

// Reference Frames Table Schema
const String createReferenceFrameTable = '''
CREATE TABLE Exercise_Reference_Frames (
  Reference_Frame_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Exercise_ID INTEGER NOT NULL,
  Frame_Number INTEGER NOT NULL,
  Timestamp REAL NOT NULL,
  Pose_Json TEXT NOT NULL,
  FOREIGN KEY (Exercise_ID) REFERENCES Exercises(Exercise_ID)
);
''';

// Performance Metrics Table Schema
const String createSessionPerformanceMetricsTable = '''
CREATE TABLE IF NOT EXISTS Session_Performance_Metrics (
  Metrics_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Session_ID INTEGER NOT NULL,

  Pipeline_Version TEXT NOT NULL,

  Frames_Received INTEGER DEFAULT 0,
  Frames_Scored INTEGER DEFAULT 0,
  Frames_Missing_Reference INTEGER DEFAULT 0,

  Avg_Accuracy REAL,

  Avg_Frame_Pipeline_Ms REAL,
  P95_Frame_Pipeline_Ms REAL,

  Avg_Db_Session_Frame_Insert_Ms REAL,
  P95_Db_Session_Frame_Insert_Ms REAL,

  Avg_Accuracy_Compute_Ms REAL,
  P95_Accuracy_Compute_Ms REAL,

  Created_At DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (Session_ID) REFERENCES Sessions(Session_ID) ON DELETE CASCADE
);
''';