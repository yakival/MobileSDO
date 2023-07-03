import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import 'Database.dart';

Config clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Config.fromMap(jsonData);
}

String clientToJson(Config data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Config {
  int? id;
  String? username;
  String? password;
  String? url;
  String? notify;
  bool? changed;
  int? newNotification;
  int? lastNotification;

  Config({
    this.id,
    this.username,
    this.password,
    this.url,
    this.notify,
    this.changed,
    this.newNotification,
    this.lastNotification,
  });

  factory Config.fromMap(Map<String, dynamic> json) => Config(
        id: json["id"],
        username: json["username"],
        password: json["password"],
        url: json["url"],
        notify: json["notify"],
        changed: json["changed"],
        newNotification: json["newNotification"],
        lastNotification: json["lastNotification"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "username": username,
        "password": password,
        "url": url,
        "notify": notify,
        "changed": changed,
        "newNotification": newNotification,
        "lastNotification": lastNotification,
      };
}

updateConfig(Config newClient) async {
  Database db = await DBProvider.db.database as Database;
  db.rawDelete("Delete from Config");
  var raw = await db.rawInsert(
      "INSERT Into Config (username,password,url,notify,newNotification,lastNotification)"
      " VALUES (?,?,?,?,(select count(*) from Notify where (dtview is NULL) and (remove=0 or (remove is NULL))),?)",
      [
        newClient.username,
        newClient.password,
        newClient.url,
        newClient.notify,
        newClient.lastNotification
      ]);
  return raw;
}

getConfig() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.rawQuery(
      "select username,password,url,notify,(select count(*) from Notify where (dtview is NULL) and (remove=0 or (remove is NULL))) as newNotification,lastNotification from Config");
  if (res.isEmpty) {
    await db.rawInsert(
        "INSERT Into Config (username,password,url,notify,newNotification,lastNotification)"
        " VALUES (?,?,?,?,?,?)",
        ['p5013user89', '1234567', 'https://myapp.prometeus.ru', '[]']);
    res = await db.rawQuery(
        "select username,password,url,notify,(select count(*) from Notify where (dtview is NULL) and (remove=0 or (remove is NULL))) as newNotification,lastNotification from Config");
  }
  return (res.isNotEmpty) && res.isNotEmpty ? Config.fromMap(res.first) : null;
}
