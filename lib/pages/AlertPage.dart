import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:photo_view/photo_view.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({Key? key}) : super(key: key);

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<AlertPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;
    final item = args[0] as Item;
    final lst = (args[1] != null) ? args[1] as List<Item> : [];

    return Scaffold(
        appBar: AppBar(
          title: Text(item.name!),
        ),
        bottomNavigationBar:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                Navigator.of(context).pop();
              });
            },
            child: const Text('Оглавление'),
          ),
        ]),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: Column(
                children: <Widget>[
                  const Text("Доступ не разрешен. Причина:",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 30,
                    width: 30,
                  ),
                  (lst.isNotEmpty)
                      ? const Text(
                          "Вы потратили недостаточно времени на изучение материалов курса:")
                      : Container(),
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.top,
                    children: lst
                        .map((e) => TableRow(
                              children: [
                                TableCell(
                                    child: Container(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    150) /
                                                2,
                                        child: Column(children: <Widget>[
                                          Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0.00, 20.00, 0.00, 0.00),
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(e.name!,
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ]))),
                              ],
                            ))
                        .toList(),
                  ),
                  const SizedBox(
                    height: 30,
                    width: 30,
                  ),
                  (lst.isNotEmpty)
                      ? const Text("Вернитесь к изучению теории.")
                      : const Text("У вас нет действующих допусков."),
                ],
              ),
            ),
          ),
        ));
  }
}
