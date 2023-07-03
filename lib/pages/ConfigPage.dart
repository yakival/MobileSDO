import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/database/ConfigModel.dart';
import 'package:myapp/database/CourseModel.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/database/WebinarModel.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'package:myapp/widgets/config.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:path_provider/path_provider.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  String? _username = GlobalData.username;
  String? _url = GlobalData.baseUrl;
  String? _password = GlobalData.password;
  List<dynamic>? _notify = [];
  int _stackToView = 0;

  @override
  void initState() {
    super.initState();
    if(GlobalData.notify != null) {
      _notify = (json.decode(GlobalData.notify!) as List).toList();
    }
  }

  List<DataRow> _getData() {
    List<DataRow> _list = [];

    for (var itm in _notify!) {
      _list.add(DataRow(
        cells: [
          DataCell(
            Text(
              itm["name"],
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          DataCell(Container(
            width: 70, //SET width
            child: Checkbox(
              checkColor: Colors.white,
              value: itm["email"],
              onChanged: (bool? value) {
                setState(() {
                  itm["email"] = value!;
                });
              },
            ),
          )),
          DataCell(Container(
            width: 50, //SET width
            child: Checkbox(
              checkColor: Colors.white,
              value: itm["sdo"],
              onChanged: (bool? value) {
                setState(() {
                  itm["sdo"] = value!;
                });
              },
            ),
          )),
        ],
      ));
    }

    return _list;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Настройки'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.account_circle)),
                Tab(icon: Icon(Icons.message)),
              ],
            ),
          ),
          bottomNavigationBar: const BottomMenu(),
          body: TabBarView(children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                    child: IndexedStack(index: _stackToView, children: <Widget>[
                  Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                                child: Row(
                                  children: const [
                                    Flexible(
                                        child: Text(
                                            "Усли вы не знаете URL, спросите его в отделе обучения или у вашего руководителя.",
                                            style: TextStyle(
                                              color: Colors.black45,
                                            ))),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Icon(
                                      Icons.help_outline,
                                      color: Colors.black45,
                                    ),
                                  ],
                                )),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'URL учётной записи',
                              ),
                              initialValue: GlobalData.baseUrl,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Укажите значение';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _url = value;
                              },
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 32.0, 0, 0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.green,
                                        onPrimary: Colors.white),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        // Process data.
                                        setState(() {
                                          _stackToView = 1;
                                        });
                                      }
                                    },
                                    child: const Text('Далее'),
                                  ),
                                )),
                          ])),
                  Form(
                      key: _formKey1,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                                child: Text(
                                  'Имя пользователя:',
                                  style: TextStyle(fontSize: 16.0),
                                )),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Введите имя пользователя',
                              ),
                              initialValue: GlobalData.username,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Укажите значение';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _username = value;
                              },
                            ),
                            ////////////////////////////////////////////////////////////////
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 32.0, 0, 0),
                                child: Text(
                                  'Пароль:',
                                  style: TextStyle(fontSize: 16.0),
                                )),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Введите пароль',
                              ),
                              obscureText: true,
                              initialValue: GlobalData.password,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Укажите значение';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _password = value;
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 32.0, 0, 0),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.green,
                                        onPrimary: Colors.white),
                                    onPressed: () async {
                                      if (_formKey1.currentState!.validate()) {
                                        // Process data.
                                        if (_username != GlobalData.username) {
                                          final documentsDirectory =
                                              await getApplicationDocumentsDirectory();
                                          Directory(
                                                  '${documentsDirectory.path}/storage')
                                              .deleteSync(recursive: true);
                                          Directory(
                                                  '${documentsDirectory.path}/storage')
                                              .createSync(recursive: true);
                                          await deleteAllWebinar();
                                          await deleteAllItem();
                                          await deleteAllCourse();
                                          GlobalData.isReadAll = false;
                                        }
                                        await updateConfig(Config(
                                          username: _username,
                                          password: _password,
                                          url: _url,
                                        ));
                                        await initGlobalData();
                                        setState(() {
                                          _stackToView = 0;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content:
                                              Text('Данные успешно сохранены'),
                                          backgroundColor: Colors.green,
                                        ));
                                      }
                                    },
                                    child: const Text('Сохранить настройки'),
                                  )),
                            ),
                          ])),
                ]))),
            Center(
                child: ListView(children: [
              DataTable(
                columnSpacing: 1,
                columns: const [
                  DataColumn(
                    label: Text(
                      "Получать уведомления:",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "на e-mail",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "в СДО",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
                rows: _getData(),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(30, 32.0, 30, 0),
                  child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green, onPrimary: Colors.white),
                        onPressed: () async {
                          // Process data.
                          await updateConfig(Config(
                            username: _username,
                            password: _password,
                            url: _url,
                            notify: json.encode(_notify),
                          ));
                          await initGlobalData();
                          await httpAPI(
                              "close/students/mobileApp.asp",
                              '{"data": ${json.encode(_notify)}, "command": "setNotifySetup"}',
                              context);
                          setState(() {
                            _stackToView = 0;
                          });
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Данные успешно сохранены'),
                            backgroundColor: Colors.green,
                          ));
                        },
                        child: const Text('Сохранить настройки'),
                      ))),
            ])),
          ]),
        ));
  }
}
