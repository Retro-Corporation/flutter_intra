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