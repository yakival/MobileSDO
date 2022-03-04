import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static const String dname = 'database.db';

  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dname);
    return await openDatabase(path, version: 22, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      var batch = db.batch();
      _createTableConfig(batch);
      _createTableCourse(batch);
      _createTableItems(batch);
      _createTableWebinars(batch);
      await batch.commit();
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      var batch = db.batch();
      if (oldVersion < 22) {
        _createTableCourse(batch);
        _createTableItems(batch);
        _createTableWebinars(batch);
      }
      await batch.commit();
    });
  }

  /// Create Config
  void _createTableConfig(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS Config');
    batch.execute('''CREATE TABLE Config (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      password TEXT,
      url TEXT
    )''');
  }

  /// Create Course
  void _createTableCourse(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS Course');
    batch.execute('''CREATE TABLE Course (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      guid TEXT,
      name TEXT,
      modulename TEXT,
      description TEXT,
      load TINYINT(1),
      dtend DATETIME
    )''');
  }

  /// Create Items
  void _createTableItems(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS Items');
    batch.execute('''CREATE TABLE Items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      courseid INTEGER,
      guid TEXT,
      name TEXT,
      description TEXT,
      type TEXT,
      path TEXT,
      localpath TEXT,
      jsondata TEXT,
      exec TINYINT(1),
      dtexec DATETIME,
      sync TINYINT(1),
      load TINYINT(1)
    )''');
    batch.execute('''CREATE INDEX "items_course_index" ON "items" (
	    "courseid"
    )''');
  }

  /// Create Webinars
  void _createTableWebinars(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS Webinars');
    batch.execute('''CREATE TABLE Webinars (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      eventid INTEGER,
      name TEXT,
      author TEXT,
      type TEXT,
      url TEXT,
      dtfrom DATETIME,
      dtto DATETIME
    )''');
    batch.execute('''CREATE INDEX "webinars_event_index" ON "webinars" (
	    "eventid"
    )''');
  }
}
