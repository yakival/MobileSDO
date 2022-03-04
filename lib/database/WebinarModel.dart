import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'Database.dart';

Webinar clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Webinar.fromMap(jsonData);
}

String clientToJson(Webinar data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Webinar {
  int? id;
  int? eventid;
  String? name;
  String? author;
  String? type;
  String? url;
  DateTime? dtfrom;
  DateTime? dtto;

  Webinar(
      {this.id,
      this.eventid,
      this.name,
      this.author,
      this.type,
      this.url,
      this.dtfrom,
      this.dtto});

  factory Webinar.fromMap(Map<String, dynamic> json) => Webinar(
        id: json["id"],
        eventid: json["eventid"],
        name: json["name"],
        author: json["author"],
        type: json["type"],
        url: json["url"],
        dtfrom: DateTime.parse(json["dtfrom"].toString()),
        dtto: DateTime.parse(json["dtto"].toString()),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "eventid": eventid,
        "name": name,
        "author": author,
        "type": type,
        "url": url,
        "dtfrom": dtfrom,
        "dtto": dtto,
      };
}

newWebinar(Webinar newClient) async {
  Database db = await DBProvider.db.database as Database;
  //get the biggest id in the table
  var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Webinars");
  var id = table.first["id"];
  id ??= 1;
  //insert to the table using the new id
  var raw = await db.rawInsert(
      "INSERT Into Webinars(id,eventid,name,author,type,url,dtfrom,dtto)"
      " VALUES (?,?,?,?,?,?,?,?)",
      [
        id,
        newClient.eventid,
        newClient.name,
        newClient.author,
        newClient.type,
        newClient.url,
        DateFormat('yyyy-MM-dd HH:mm').format(newClient.dtfrom!),
        DateFormat('yyyy-MM-dd HH:mm').format(newClient.dtto!),
      ]);
  return raw;
}

updateWebinar(Webinar newClient) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.update("Webinars", newClient.toMap(),
      where: "id = ?", whereArgs: [newClient.id]);
  return res;
}

getWebinar(int id) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Webinars", where: "id = ?", whereArgs: [id]);
  return (res.isNotEmpty) && res.isNotEmpty ? Webinar.fromMap(res.first) : null;
}

getWebinarGuid(String guid) async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Webinars", where: "guid = ?", whereArgs: [guid]);
  return (res.isNotEmpty) && res.isNotEmpty ? Webinar.fromMap(res.first) : null;
}

Future<List<Webinar>> getAllWebinar() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.query("Webinars");
  List<Webinar> list =
      res.isNotEmpty ? res.map((c) => Webinar.fromMap(c)).toList() : [];
  return list;
}

deleteWebinar(int id) async {
  Database db = await DBProvider.db.database as Database;
  return db.delete("Webinars", where: "id = ?", whereArgs: [id]);
}

deleteAllWebinar() async {
  Database db = await DBProvider.db.database as Database;
  db.rawDelete("Delete from Webinars");
}
