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
    final checkPath =
        await Directory('${documentsDirectory.path}/storage').exists();
    if (!checkPath) {
      Directory('${documentsDirectory.path}/storage')
          .createSync(recursive: true);
    }
    String path = join(documentsDirectory.path, dname);
    return await openDatabase(path, version: 24, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      var batch = db.batch();
      await _createTableConfig(batch);
      await _createTableCourse(batch);
      await _createTableItems(batch);
      await _createTableWebinars(batch);
      await batch.commit();
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      var batch = db.batch();
      if (oldVersion < 24) {
        await _createTableCourse(batch);
        await _createTableItems(batch);
        await _createTableWebinars(batch);

        await deleteDir('${documentsDirectory.path}/storage');
      }
      await batch.commit();
    });
  }

  Future<void> deleteDir(dir) async {
    final directory = Directory(dir);
    var _folders = directory.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity fl in _folders) {
      fl.deleteSync();
    }
  }

  /// Create Config
  Future<void> _createTableConfig(Batch batch) async {
    batch.execute('DROP TABLE IF EXISTS Config');
    batch.execute('''CREATE TABLE Config (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      password TEXT,
      url TEXT
    )''');
  }

  /// Create Course
  Future<void> _createTableCourse(Batch batch) async {
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
  Future<void> _createTableItems(Batch batch) async {
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
      load TINYINT(1),
      menu TINYINT(1)
    )''');
    batch.execute('''CREATE INDEX "items_course_index" ON "items" (
	    "courseid"
    )''');
  }

  /// Create Webinars
  Future<void> _createTableWebinars(Batch batch) async {
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
