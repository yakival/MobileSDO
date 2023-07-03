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
  String? modulename;
  String? name;
  String? description;
  String? type;
  String? path;
  String? localpath;
  String? jsondata;
  String? links;
  String? access;
  String? history;
  int? rate;
  int? time;
  String? attempt;
  DateTime? dtexec;
  bool? exec = false;
  bool? sync = false;
  bool? checked = false;
  bool? load = false;
  bool? menu = false;

  Item(
      {this.id,
      this.courseid,
      this.guid,
      this.modulename,
      this.name,
      this.description,
      this.type,
      this.path,
      this.localpath,
      this.jsondata,
      this.access,
      this.history,
      this.links,
      this.rate,
      this.time,
      this.attempt,
      this.dtexec,
      this.exec,
      this.sync,
      this.load,
      this.menu,
      this.checked});

  factory Item.fromMap(Map<String, dynamic> json) => Item(
        id: json["id"],
        courseid: json["courseid"],
        guid: json["guid"],
        modulename: json["modulename"],
        name: json["name"],
        description: json["description"],
        type: json["type"],
        path: json["path"],
        localpath: json["localpath"],
        jsondata: json["jsondata"],
        access: json["access"],
        history: json["history"],
        links: json["links"],
        rate: json["rate"],
        time: json["time"],
        attempt: json["attempt"],
        dtexec: (json["dtexec"] == null)
            ? null
            : DateTime.parse(json["dtexec"].toString()),
        exec: json["exec"] == 1,
        sync: json["sync"] == 1,
        load: json["load"] == 1,
        menu: json["menu"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "courseid": courseid,
        "guid": guid,
        "modulename": modulename,
        "name": name,
        "description": description,
        "type": type,
        "path": path,
        "localpath": localpath,
        "jsondata": jsondata,
        "access": access,
        "history": history,
        "links": links,
        "rate": rate,
        "time": time,
        "attempt": attempt,
        "dtexec": dtexec?.toIso8601String(),
        "exec": exec,
        "sync": sync,
        "load": load,
        "menu": menu,
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
      "INSERT Into Items (id,courseid,guid,modulename,name,description,type,path,localpath,jsondata,access,history,links,rate,time,attempt,load,sync,menu)"
      " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
      [
        id,
        newClient.courseid,
        newClient.guid,
        newClient.modulename,
        newClient.name,
        newClient.description,
        newClient.type,
        newClient.path,
        newClient.localpath,
        newClient.jsondata,
        newClient.access,
        newClient.history,
        newClient.links,
        newClient.rate,
        newClient.time,
        newClient.attempt,
        newClient.load,
        newClient.sync,
        newClient.menu,
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
  var res = await db.query("Items", orderBy: "id desc");
  List<Item> list =
      res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
  return list;
}

Future<List<Item>> getCourseItem(id) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Items", where: "courseid = ?", whereArgs: [id], orderBy: "id desc");
  List<Item> list =
      res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
  return list;
}

Future<List<Item>> getFreeItem() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Items", where: "courseid = ?", whereArgs: [0], orderBy: "id desc");
  List<Item> list =
      res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
  return list;
}

deleteItem(Item item) async {
  if (File(item.path!).existsSync()) {
    File(item.path!).deleteSync(recursive: true);
  }
  Database db = await DBProvider.db.database as Database;
  return db.delete("Items", where: "id = ?", whereArgs: [item.id]);
}

deleteAllItem() async {
  Database db = await DBProvider.db.database as Database;
  db.rawDelete("Delete from Items");
}
