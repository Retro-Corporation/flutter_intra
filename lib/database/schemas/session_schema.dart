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