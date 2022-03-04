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
  String? name;
  String? moduleName;
  String? description;
  DateTime? dtend;
  bool? load = false;
  bool? checked = false;

  Course(
      {this.id,
      this.guid,
      this.name,
      this.moduleName,
      this.description,
      this.dtend,
      this.load,
      this.checked});

  factory Course.fromMap(Map<String, dynamic> json) => Course(
        id: json["id"],
        guid: json["guid"],
        name: json["name"],
        moduleName: json["modulename"],
        description: json["description"],
        load: json["load"] == 1,
        dtend: json["dtend"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "moduleName": moduleName,
        "guid": guid,
        "description": description,
        "load": load,
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
      "INSERT Into Course (id,guid,name,modulename,description,load)"
      " VALUES (?,?,?,?,?,?)",
      [
        id,
        newClient.guid,
        newClient.name,
        newClient.moduleName,
        newClient.description,
        newClient.load,
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
