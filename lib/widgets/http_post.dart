import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:myapp/widgets/config.dart';

Future<bool> hasNetwork(context) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Нет подключения к интернету'),
    backgroundColor: Colors.red,
  ));
  return false;
}

Future<Object> httpAPI(url1, params, context) async {
  var _username = GlobalData.username;
  var _password = GlobalData.password;
  var _url = GlobalData.baseUrl;
  var auth = 'Basic ' + base64Encode(utf8.encode('$_username:$_password'));

  var isOnline = await hasNetwork(context);

  if (isOnline) {
    final response =
        await post(Uri.parse('$_url/$url1'), body: params, // {'param': param},
            headers: <String, String>{
          'Authorization': auth,
          HttpHeaders.contentTypeHeader: "application/json",
        });

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json.length > 0) {
        if (json!["error"] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(json!["error"].toString()),
            backgroundColor: Colors.red,
          ));
          return jsonDecode("{}");
        } else {
          return json!["data"];
        }
      } else {
        return json;
      }
    } else {
      if (response.statusCode == 401 || response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ошибка авторизации на сервере'),
          backgroundColor: Colors.red,
        ));
        return jsonDecode("{}");
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        //throw Exception('Ошибка обращения к серверу.');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ошибка обращения к серверу'),
          backgroundColor: Colors.red,
        ));
        return jsonDecode("{}");
      }
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Нет подключения к интернету'),
      backgroundColor: Colors.red,
    ));
    return jsonDecode("[]");
  }
}
