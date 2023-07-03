import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/database/ConfigModel.dart';
import 'package:myapp/database/NotifyModel.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'package:myapp/widgets/config.dart';
import 'package:myapp/widgets/http_post.dart';

class NotifyPage extends StatefulWidget {
  const NotifyPage({
    Key? key,
  }) : super(key: key);

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  List<dynamic>? _notify;

  @override
  void initState() {
    super.initState();
  }

  Future<List<Notify>> _getData(int count) async {
    final List<Notify> list = await getAllNotify();
    List<Notify> list_ = [];
    for (Notify itm in list) {
      if (!(itm.remove ?? false)) {
        list_.add(itm);
      }
    }
    return list_;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Уведомления'),
          actions: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: (args > 0)
                        ? TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                            ),
                            child: const Text('Показать все'),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/notify',
                                  arguments: 0);
                            },
                          )
                        : null),
              ],
            )
          ],
        ),
        bottomNavigationBar: const BottomMenu(),
        body: FutureBuilder<List<Notify>>(
            future: _getData(args),
            builder:
                (BuildContext context, AsyncSnapshot<List<Notify>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      Notify item = snapshot.data![index];
                      return Card(
                          child: ListTile(
                        //isThreeLine: true,
                        title: Text(
                          item.subject!,
                          style: TextStyle(
                              fontWeight: (item.dtview == null)
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                        subtitle: Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(item.dt!),
                          style: TextStyle(
                              fontWeight: (item.dtview == null)
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                        trailing: FittedBox(
                            fit: BoxFit.fill,
                            child: Row(children: <Widget>[
                              IconButton(
                                  icon: const Icon(
                                    Icons.delete_sweep,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    item.remove = true;
                                    updateNotify(item);
                                    setState(() {});
                                  }),
                            ])),
                        onTap: () async {
                          Navigator.pushNamed(context, '/message',
                                  arguments: item)
                              .then((value) {
                            setState(() {});
                          });
                        },
                      ));
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
