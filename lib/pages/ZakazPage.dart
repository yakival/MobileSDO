import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'package:myapp/widgets/http_post.dart';

class ZakazPage extends StatefulWidget {
  const ZakazPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ZakazPage> createState() => _ZakazPageState();
}

class _ZakazPageState extends State<ZakazPage> {
  bool isLoad = false;
  List<dynamic> _listItem = [];
  int _stackToView = 0;
  var _currElement;
  String? _radio;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    var isOnline = await hasNetwork(context);
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Нет подключения к интернету'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    var res_ = await httpAPI("close/students/mobileApp.asp",
        '{"command": "getCoursesZakaz"}', context);
    _listItem = (res_ as List).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказ курсов'),
      ),
      bottomNavigationBar: (isLoad) ? null : const BottomMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IndexedStack(
          index: _stackToView,
          children: [
            //0 - ВЫБОР КУРСА
            GroupedListView<dynamic, String>(
              elements: _listItem,
              groupBy: (element) => element['CategoryName'],
              groupComparator: (value1, value2) => value2.compareTo(value1),
              itemComparator: (item1, item2) =>
                  item1['CourseName'].compareTo(item2['CourseName']),
              order: GroupedListOrder.DESC,
              useStickyGroupSeparators: true,
              groupSeparatorBuilder: (String value) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              itemBuilder: (c, element) {
                return Card(
                  elevation: 8.0,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      title: Text(element['CourseName']),
                      subtitle: Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Colors.blue,
                          ),
                          Text(element["CourseDuration"].toString()),
                          const SizedBox(
                            width: 30,
                          ),
                          const Icon(
                            Icons.credit_card,
                            color: Colors.blue,
                          ),
                          Text(element["CoursePrice"].toString()),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(element["CourseCurrency"].toString()),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        setState(() {
                          _currElement = element;
                          _stackToView = 1;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            //1 - ЗАКАЗ КУРСА
            (_currElement == null)
                ? Container()
                : Column(
                    children: <Widget>[
                      Row(children: const [
                        Text(
                          "РЕГИСТРАЦИЯ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]),
                      Container(
                        padding: const EdgeInsets.all(5.00),
                      ),
                      Row(children: [
                        Text(
                          _currElement["CourseName"],
                          textAlign: TextAlign.left,
                        ),
                      ]),
                      Container(
                        padding: const EdgeInsets.all(5.00),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Colors.blue,
                          ),
                          Text(_currElement["CourseDuration"].toString()),
                          const SizedBox(
                            width: 30,
                          ),
                          const Icon(
                            Icons.credit_card,
                            color: Colors.blue,
                          ),
                          Text(_currElement["CoursePrice"].toString()),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(_currElement["CourseCurrency"].toString()),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.00),
                      ),
                      Row(children: const [
                        Text(
                          "Выберите дату начала обучения",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ]),
                      Row(children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Table(
                          columnWidths: const <int, TableColumnWidth>{
                            0: FixedColumnWidth(40.0),
                            1: FixedColumnWidth(200.00),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: (_currElement["groups"] as List)
                              .map(
                                (e) => TableRow(
                                  children: [
                                    TableCell(
                                        child: Radio(
                                      value: e["GroupId"],
                                      groupValue: _radio,
                                      onChanged: (dynamic? value) {
                                        setState(() {
                                          _radio = value as String?;
                                        });
                                      },
                                    )),
                                    TableCell(
                                        child: Text(DateFormat('dd.MM.yyyy')
                                            .format(DateTime.parse(
                                                e["GroupDateStart"])))),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ]),
                      Container(
                        padding: const EdgeInsets.all(15.00),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (_radio != null)
                                ? ElevatedButton(
                                    onPressed: () async {
                                      var res_ = await httpAPI(
                                          "close/students/mobileApp.asp",
                                          '{"command": "putCourseZakaz", "group": "' +
                                              _radio! +
                                              '", "price": "' +
                                              _currElement["CoursePrice"] +
                                              '", "curr": "' +
                                              _currElement["CourseCurrency"] +
                                              '"}',
                                          context);
                                      _radio = null;
                                      if ((res_ as Map<String, dynamic>)[
                                              "status"] ==
                                          "ok") {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('Заявка оформлена'),
                                          backgroundColor: Colors.green,
                                        ));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content:
                                              Text('Ошибка оформления заявки'),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                      Navigator.pushReplacementNamed(
                                          context, '/');
                                    },
                                    child: const Text('Отправить заявку'),
                                  )
                                : Container(),
                            const SizedBox(
                              height: 30,
                              width: 30,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: const Color(0xFFf4f4f4),
                                  onPrimary: Colors.black),
                              onPressed: () {
                                setState(() {
                                  _stackToView = 0;
                                });
                              },
                              child: const Text('Отменить'),
                            ),
                          ])
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
