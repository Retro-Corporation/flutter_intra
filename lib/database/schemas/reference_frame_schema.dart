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