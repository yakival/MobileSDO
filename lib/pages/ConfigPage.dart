import 'package:flutter/material.dart';
import 'package:myapp/database/ConfigModel.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'package:myapp/widgets/config.dart';

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
  int _stackToView = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход на учебный портал'),
      ),
      bottomNavigationBar: const BottomMenu(),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: IndexedStack(index: _stackToView, children: <Widget>[
            Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                          padding: const EdgeInsets.fromLTRB(0, 32.0, 0, 0),
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
                                  await updateConfig(Config(
                                    username: _username,
                                    password: _password,
                                    url: _url,
                                  ));
                                  await initGlobalData();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('Данные успешно сохранены'),
                                    backgroundColor: Colors.green,
                                  ));
                                }
                              },
                              child: const Text('Сохранить настройки'),
                            )),
                      ),
                    ])),
          ]))),
    );
  }
}
