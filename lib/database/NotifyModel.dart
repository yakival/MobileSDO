import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'Database.dart';

Notify clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Notify.fromMap(jsonData);
}

String clientToJson(Notify data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Notify {
  int? id;
  String? from;
  String? subject;
  String? body;
  DateTime? dt;
  DateTime? dtview;
  bool? sync = false;
  bool? remove = false;

  Notify(
      {this.id,
      this.from,
      this.subject,
      this.body,
      this.dt,
      this.dtview,
      this.sync,
      this.remove});

  factory Notify.fromMap(Map<String, dynamic> json) => Notify(
        id: json["id"],
        from: json["from"],
        subject: json["subject"],
        body: json["body"],
        dt: (json["dt"] == null) ? null : DateTime.parse(json["dt"].toString()),
        dtview: (json["dtview"] == null)
            ? null
            : DateTime.parse(json["dtview"].toString()),
        sync: json["sync"] == 1,
        remove: json["remove"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "from": from,
        "subject": subject,
        "body": body,
        "dt": dt?.toIso8601String(),
        "dtview": dtview?.toIso8601String(),
        "sync": sync,
        "remove": remove,
      };
}

newNotify(Notify newClient) async {
  Database db = await DBProvider.db.database as Database;
  //get the biggest id in the table
  //var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Notify");
  //var id = table.first["id"];
  //id ??= 1;
  //insert to the table using the new id
  var raw = await db.rawInsert(
      'INSERT Into Notify (id,"from",subject,body,dt,dtview,sync,remove) VALUES (?,?,?,?,?,?,?,?)',
      [
        newClient.id,
        newClient.from,
        newClient.subject,
        newClient.body,
        DateFormat('yyyy-MM-dd HH:mm').format(newClient.dt!),
        (newClient.dtview == null)
            ? null
            : DateFormat('yyyy-MM-dd HH:mm').format(newClient.dtview!),
        newClient.sync,
        newClient.remove,
      ]);
  return raw;
}

updateNotify(Notify newClient) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.update("Notify", newClient.toMap(),
      where: "id = ?", whereArgs: [newClient.id]);
  return res;
}

getNotify(int id) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Notify", where: "id = ?", whereArgs: [id]);
  return (res.isNotEmpty) && res.isNotEmpty ? Notify.fromMap(res.first) : null;
}

Future<List<Notify>> getAllNotify() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Notify", orderBy: "id desc");
  List<Notify> list =
      res.isNotEmpty ? res.map((c) => Notify.fromMap(c)).toList() : [];
  return list;
}

Future<List<Notify>> getNewNotify() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Notify",
      where: "(dtview is NULL) and (remove=0 or (remove is NULL))");
  List<Notify> list =
      res.isNotEmpty ? res.map((c) => Notify.fromMap(c)).toList() : [];
  return list;
}

deleteNotify(Notify item) async {
  Database db = await DBProvider.db.database as Database;
  return db.delete("Notify", where: "id = ?", whereArgs: [item.id]);
}

deleteAllNotify() async {
  Database db = await DBProvider.db.database as Database;
  db.rawDelete("Delete from Notify");
}
