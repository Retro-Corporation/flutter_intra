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