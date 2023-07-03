import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import 'Database.dart';

Course clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Course.fromMap(jsonData);
}

String clientToJson(Course data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Course {
  int? id;
  String? guid;
  String? orderid;
  String? name;
  String? moduleName;
  String? description;
  String? cmode;
  DateTime? dtend;
  double? rate;
  bool? load = false;
  bool? checked = false;

  Course(
      {this.id,
        this.guid,
        this.orderid,
        this.name,
        this.moduleName,
        this.description,
        this.cmode,
        this.dtend,
        this.rate,
        this.load,
        this.checked});

  factory Course.fromMap(Map<String, dynamic> json) => Course(
    id: json["id"],
    guid: json["guid"],
    orderid: json["orderid"],
    name: json["name"],
    moduleName: json["modulename"],
    description: json["description"],
    cmode: json["cmode"],
    rate: json["rate"].toDouble(),
    load: json["load"] == 1,
    dtend: json["dtend"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "moduleName": moduleName,
    "guid": guid,
    "orderid": orderid,
    "description": description,
    "cmode": cmode,
    "load": load,
    "rate": rate,
    "dtend": dtend,
  };
}

newCourse(Course newClient) async {
  Database db = await DBProvider.db.database as Database;
  //get the biggest id in the table
  var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Course");
  var id = table.first["id"];
  id ??= 1;
  //insert to the table using the new id
  var raw = await db.rawInsert(
      "INSERT Into Course (id,guid,orderid,name,modulename,description,cmode,load,rate)"
          " VALUES (?,?,?,?,?,?,?,?,?)",
      [
        id,
        newClient.guid,
        newClient.orderid,
        newClient.name,
        newClient.moduleName,
        newClient.description,
        newClient.cmode,
        newClient.load,
        newClient.rate,
      ]);
  return raw;
}

updateCourse(Course newClient) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.update("Course", newClient.toMap(),
      where: "id = ?", whereArgs: [newClient.id]);
  return res;
}

getCourse(int id) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Course", where: "id = ?", whereArgs: [id]);
  return (res.isNotEmpty) && res.isNotEmpty ? Course.fromMap(res.first) : null;
}

getCourseGuid(String guid) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Course", where: "guid = ?", whereArgs: [guid]);
  return (res.isNotEmpty) && res.isNotEmpty ? Course.fromMap(res.first) : null;
}

Future<List<Course>> getAllCourse() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Course");
  List<Course> list =
  res.isNotEmpty ? res.map((c) => Course.fromMap(c)).toList() : [];
  return list;
}

deleteCourse(int id) async {
  Database db = await DBProvider.db.database as Database;
  return db.delete("Course", where: "id = ?", whereArgs: [id]);
}

deleteAllCourse() async {
  Database db = await DBProvider.db.database as Database;
  db.rawDelete("Delete from Course");
}

/////////////////////////////////////////////////////////////////////////

newCourseCompl(Course newClient) async {
  Database db = await DBProvider.db.database as Database;
  //get the biggest id in the table
  var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM CourseCompl");
  var id = table.first["id"];
  id ??= 1;
  //insert to the table using the new id
  var raw = await db.rawInsert(
      "INSERT Into CourseCompl (id,guid,orderid,name,modulename,description,cmode,load,rate)"
          " VALUES (?,?,?,?,?,?,?,?,?)",
      [
        id,
        newClient.guid,
        newClient.orderid,
        newClient.name,
        newClient.moduleName,
        newClient.description,
        newClient.cmode,
        newClient.load,
        newClient.rate,
      ]);
  return raw;
}

updateCourseCompl(Course newClient) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.update("CourseCompl", newClient.toMap(),
      where: "id = ?", whereArgs: [newClient.id]);
  return res;
}

getCourseCompl(int id) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("CourseCompl", where: "id = ?", whereArgs: [id]);
  return (res.isNotEmpty) && res.isNotEmpty ? Course.fromMap(res.first) : null;
}

getCourseGuidCompl(String guid) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("CourseCompl", where: "guid = ?", whereArgs: [guid]);
  return (res.isNotEmpty) && res.isNotEmpty ? Course.fromMap(res.first) : null;
}

Future<List<Course>> getAllCourseCompl() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("CourseCompl");
  List<Course> list =
  res.isNotEmpty ? res.map((c) => Course.fromMap(c)).toList() : [];
  return list;
}

deleteCourseCompl(int id) async {
  Database db = await DBProvider.db.database as Database;
  return db.delete("CourseCompl", where: "id = ?", whereArgs: [id]);
}

deleteAllCourseCompl() async {
  Database db = await DBProvider.db.database as Database;
  db.rawDelete("Delete from CourseCompl");
}
