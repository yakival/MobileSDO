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
    //if (_database != null) return _database;
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
    const ver = 87;
    return await openDatabase(path, version: ver, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      var batch = db.batch();
      await _createTableConfig(batch);
      await _createTableCourse(batch);
      await _createTableCourseCompl(batch);
      await _createTableItems(batch);
      await _createTableWebinars(batch);
      await _createTableNotify(batch);
      await batch.commit();
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      var batch = db.batch();
      if (oldVersion < ver) {
        await _createTableConfig(batch);
        await _createTableCourse(batch);
        await _createTableCourseCompl(batch);
        await _createTableItems(batch);
        await _createTableWebinars(batch);
        await _createTableNotify(batch);

        Directory('${documentsDirectory.path}/storage')
            .deleteSync(recursive: true);
        Directory('${documentsDirectory.path}/storage')
            .createSync(recursive: true);
        // await deleteDir('${documentsDirectory.path}/storage');
      }
      await batch.commit();
    });
  }

  Future<void> deleteDir(dir) async {
    final directory = Directory(dir);
    var _folders = directory.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity fl in _folders) {
      fl.deleteSync(recursive: true);
    }
  }

  /// Create Config
  Future<void> _createTableConfig(Batch batch) async {
    batch.execute('DROP TABLE IF EXISTS Config');
    batch.execute('''CREATE TABLE Config (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      password TEXT,
      url TEXT,
      notify TEXT,
      newNotification INTEGER,
      lastNotification INTEGER
    )''');
  }

  /// Create Course
  Future<void> _createTableCourse(Batch batch) async {
    batch.execute('DROP TABLE IF EXISTS Course');
    batch.execute('''CREATE TABLE Course (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      guid TEXT,
      orderid TEXT,
      name TEXT,
      modulename TEXT,
      description TEXT,
      cmode TEXT,
      load TINYINT(1),
      rate NUMERIC,
      dtend DATETIME
    )''');
  }

  /// Create CourseCompl
  Future<void> _createTableCourseCompl(Batch batch) async {
    batch.execute('DROP TABLE IF EXISTS CourseCompl');
    batch.execute('''CREATE TABLE CourseCompl (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      guid TEXT,
      orderid TEXT,
      name TEXT,
      modulename TEXT,
      description TEXT,
      cmode TEXT,
      load TINYINT(1),
      rate NUMERIC,
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
      modulename TEXT,
      name TEXT,
      description TEXT,
      type TEXT,
      path TEXT,
      localpath TEXT,
      jsondata TEXT,
      access TEXT,
      history TEXT,
      links TEXT,
      rate INT,
      time INT,
      attempt TEXT,
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

  /// Create Notify Config
  Future<void> _createTableNotify(Batch batch) async {
    batch.execute('DROP TABLE IF EXISTS Notify');
    batch.execute('''CREATE TABLE Notify (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      subject TEXT,
      body TEXT,
      "from" TEXT,
      dt DATETIME,
      dtview DATETIME,
      sync TINYINT(1),
      remove TINYINT(1)
    )''');
  }
}
