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

  Config({
    this.id,
    this.username,
    this.password,
    this.url,
  });

  factory Config.fromMap(Map<String, dynamic> json) => Config(
        id: json["id"],
        username: json["username"],
        password: json["password"],
        url: json["url"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "username": username,
        "password": password,
        "url": url,
      };
}

updateConfig(Config newClient) async {
  Database db = await DBProvider.db.database as Database;
  db.rawDelete("Delete from Config");
  var raw = await db.rawInsert(
      "INSERT Into Config (username,password,url)"
      " VALUES (?,?,?)",
      [newClient.username, newClient.password, newClient.url]);
  return raw;
}

getConfig() async {
  Database db = await DBProvider.db.database as Database;
  var res = await db.rawQuery("select * from Config");
  if (res.isEmpty) {
    await db.rawInsert(
        "INSERT Into Config (username,password,url)"
        " VALUES (?,?,?)",
        ['test1', 'test1', 'http://vto.prometeus.ru:8294']);
    res = await db.rawQuery("select * from Config");
  }
  return (res.isNotEmpty) && res.isNotEmpty ? Config.fromMap(res.first) : null;
}
