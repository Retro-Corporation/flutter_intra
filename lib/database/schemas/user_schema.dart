const String createUserTable = '''
CREATE TABLE Users (
  User_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  User_Name TEXT NOT NULL,
  User_Password TEXT NOT NULL,
  Created_At DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';