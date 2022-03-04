import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';

import 'Database.dart';

Item clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Item.fromMap(jsonData);
}

String clientToJson(Item data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Item {
  int? id;
  int? courseid;
  String? guid;
  String? name;
  String? description;
  String? type;
  String? path;
  String? localpath;
  String? jsondata;
  int? attempt;
  DateTime? dtexec;
  bool? exec = false;
  bool? sync = false;
  bool? checked = false;
  bool? load = false;

  Item(
      {this.id,
      this.courseid,
      this.guid,
      this.name,
      this.description,
      this.type,
      this.path,
      this.localpath,
      this.jsondata,
      this.attempt,
      this.dtexec,
      this.exec,
      this.sync,
      this.load,
      this.checked});

  factory Item.fromMap(Map<String, dynamic> json) => Item(
        id: json["id"],
        courseid: json["courseid"],
        guid: json["guid"],
        name: json["name"],
        description: json["description"],
        type: json["type"],
        path: json["path"],
        localpath: json["localpath"],
        jsondata: json["jsondata"],
        dtexec: json["dtexec"],
        exec: json["exec"] == 1,
        sync: json["sync"] == 1,
        load: json["load"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "courseid": courseid,
        "guid": guid,
        "name": name,
        "description": description,
        "type": type,
        "path": path,
        "localpath": localpath,
        "jsondata": jsondata,
        "dtexec": dtexec,
        "exec": exec,
        "sync": sync,
        "load": load,
      };
}

newItem(Item newClient) async {
  Database db = await DBProvider.db.database as Database;
  //get the biggest id in the table
  var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Items");
  var id = table.first["id"];
  id ??= 1;
  //insert to the table using the new id
  var raw = await db.rawInsert(
      "INSERT Into Items (id,courseid,guid,name,description,type,path,localpath,jsondata,load,sync)"
      " VALUES (?,?,?,?,?,?,?,?,?,?,?)",
      [
        id,
        newClient.courseid,
        newClient.guid,
        newClient.name,
        newClient.description,
        newClient.type,
        newClient.path,
        newClient.localpath,
        newClient.jsondata,
        newClient.load,
        newClient.sync,
      ]);
  return raw;
}

updateItem(Item newClient) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.update("Items", newClient.toMap(),
      where: "id = ?", whereArgs: [newClient.id]);
  return res;
}

getItem(int id) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Items", where: "id = ?", whereArgs: [id]);
  return (res.isNotEmpty) && res.isNotEmpty ? Item.fromMap(res.first) : null;
}

getItemGuid(String guid) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Items", where: "guid = ?", whereArgs: [guid]);
  return (res.isNotEmpty) && res.isNotEmpty ? Item.fromMap(res.first) : null;
}

Future<List<Item>> getAllItem() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Items");
  List<Item> list =
      res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
  return list;
}

Future<List<Item>> getCourseItem(id) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Items", where: "courseid = ?", whereArgs: [id]);
  List<Item> list =
      res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
  return list;
}

Future<List<Item>> getFreeItem() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Items", where: "courseid = ?", whereArgs: [0]);
  List<Item> list =
      res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
  return list;
}

deleteItem(Item item) async {
  if (File(item.path!).existsSync()) {
    File(item.path!).delete();
  }
  Database db = await DBProvider.db.database as Database;
  return db.delete("Items", where: "id = ?", whereArgs: [item.id]);
}

deleteAllItem() async {
  Database db = await DBProvider.db.database as Database;
  db.rawDelete("Delete from Items");
}
