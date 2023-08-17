import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/pages/exam/class/Answer.dart';
import 'package:myapp/pages/exam/class/Question.dart';
import 'package:myapp/pages/exam/class/Section.dart';
import 'package:myapp/pages/exam/class/Test.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myapp/database/CourseModel.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  static const int CQTOneFromMany = 1; // один из многих
  static const int CQTManyFromMany = 2; // многие из многих
  static const int CQTInputField = 3; // поле ввода
  static const int CQTSootv = 4; // соответствие
  static const int CQTOrder = 5; // упорядочить
  static const int CQTYesNo = 6; // да/нет
  static const int CQTPicture = 7; // тыкнуть рисунок
  static const int CQTLargeField = 8; // развернутый ответ
  static const int CQTShortFields = 9; // несколько пропущенных слов
  static const int CQTManyFields = 10; // несколько полей ввода

  TTest _args = TTest();
  Item _argsItem = Item();
  int _stackToView = 0;
  Directory? testDirectory;
  TQuestion? _currQuestion;
  List<TQuestion> list_ = [];
  late ScrollController _scrollController;
  bool showAnswer = false;
  Timer? _timer;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    _startServer();
  }

  @override
  void dispose() {
    _cleanup();
    _scrollController.dispose();
    if(_timer != null) {
      _timer?.cancel();
    }
    super.dispose();
  }

  bool getNoAnswer() {
    for (TQuestion q in list_) {
      if (!(q.IsMarked ?? false)) {
        return (true);
      }
    }
    return (false);
  }

  TQuestion? getQuestion(TQuestion? value) {
    bool fnd = (value == null) ? true : false;
    if ((list_.isNotEmpty) && (value == null)) {
      value = list_[0];
    }
    for (TQuestion q in list_) {
      if (fnd) {
        if (!(q.IsMarked ?? false)) {
          return (q);
        }
      } else {
        if (q.Id == value?.Id) {
          fnd = true;
          continue;
        }
      }
    }
    return (null);
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 50), curve: Curves.linear);
  }

  String showTime(diffTime) {
    if (diffTime == null) {
      return "";
    }
    var days = diffTime / (24*60);
    var hours = (days % 1) * 24;
    var minutes = (hours % 1) * 60;
    var secs = (minutes % 1) * 60;
    var ret_ = //((days ~/ 1 > 0) ? "${days ~/ 1} дн. " : "") +
    ((hours ~/ 1 > 0) ? "${(hours ~/ 1 > 9)?"":"0"}${hours ~/ 1}:" : "00:") +
        ((minutes ~/ 1 > 0) ? "${(minutes ~/ 1 > 9)?"":"0"}${minutes ~/ 1}" : "00");
    if (ret_ == "") {
      ret_ = "00:00";
    }
    return ret_;
  }

  void setTimer(Timer timer) async {
    _argsItem.time = (_argsItem.time ?? 0) + 1;
    await updateItem(_argsItem);
    setState(() {});
    if(_argsItem.time! >= _args.TimeToTest!){
      await showDialog(
          context:
          context,
          builder:
              (BuildContext
          context) {
            return AlertDialog(
              title:
              const Text('Завершение теста'),
              content:
              const Text("Время, выделенное на выполнение теста истекло."),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      if(_args.IdType == "t") {
                        _refreshIndicatorKey.currentState?.show();
                      }else {
                        _argsItem.jsondata = jsonEncode(_args.toMap());
                        await updateItem(_argsItem);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Завершить')),
              ],
            );
          });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;
    setState(() {
      _argsItem = args[0] as Item;
      _args = args[1] as TTest;
    });

    if (testDirectory == null) return const CircularProgressIndicator();

    return Scaffold(
        appBar: AppBar(
          title: Text(_args.Name! + ((showAnswer) ? " - ОТВЕТЫ" : "")),
            actions: <Widget>[
        Row(
        children: <Widget>[
        Padding(
        padding: const EdgeInsets.fromLTRB(
            0.0, 0.0, 5.0, 0.0),
        child:
            ((_args.TimeToTest ?? 0) > 0 )?Text(showTime((_args.TimeToTest ?? 0) - (_argsItem.time ?? 0))):Container()
        ),
          ]),
        ]),
        bottomNavigationBar: (_stackToView == 1)
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () async {
                    _argsItem.exec = true;
                    await updateItem(_argsItem);
                    _timer = Timer.periodic(const Duration(minutes: 1), setTimer);
                    setState(() {
                      _scrollToTop();
                      _currQuestion = getQuestion(_currQuestion);
                      (_currQuestion == null)
                          ? _stackToView = 2
                          : _stackToView = 3;
                    });
                  },
                  child: const Text('Начать тест'),
                ),
                const SizedBox(
                  height: 30,
                  width: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xFFf4f4f4),
                      onPrimary: Colors.black),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отменить'),
                ),
              ])
            : (_stackToView == 2)
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    (getNoAnswer())
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white, onPrimary: Colors.black),
                            onPressed: () {
                              setState(() {
                                _scrollToTop();

                                _currQuestion = getQuestion(_currQuestion);
                                (_currQuestion == null)
                                    ? _stackToView = 2
                                    : _stackToView = 3;

                              });
                            },
                            child: const Text('Ответить'),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              if(_args.IdType == "t") {
                                _refreshIndicatorKey.currentState?.show();
                              }else {
                                _argsItem.jsondata = jsonEncode(_args.toMap());
                                await updateItem(_argsItem);
                                Navigator.of(context).pop();
                              }
                              return;

                              var isOnline = await hasNetwork(context);
                              if (!isOnline) {
                                return;
                              }
                              _argsItem.sync = true;
                              _argsItem.jsondata = jsonEncode(_args.toMap());
                              await updateItem(_argsItem);
                              setState(() {});
                              var json = jsonDecode(_argsItem.jsondata!);
                              for (var sec in json["sections"]) {
                                for (var q in sec["questions"]) {
                                  q["Txt"] = "";
                                }
                              }
                              var c = await getCourse(_argsItem.courseid!);
                              var res = await httpAPI(
                                  "close/students/sync.asp",
                                  '{"id": "${_argsItem.guid}", "course": "${c.guid}", "type": "TEST", "data": ' +
                                      jsonEncode(json) +
                                      '}',
                                  context) as Map<
                                  String,
                                  dynamic>;
                              _argsItem.description = res["description"];
                              _argsItem.history = null;
                              if(res["history"] != null){
                                _argsItem.history = jsonEncode(res["history"]);
                              }
                              _argsItem.sync = false;
                              await updateItem(
                                  _argsItem);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Отправить'),
                          ),
                    const SizedBox(
                      height: 30,
                      width: 30,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if(_args.IdType == "t") {
                          _refreshIndicatorKey.currentState?.show();
                        }else {
                          _argsItem.jsondata = jsonEncode(_args.toMap());
                          await updateItem(_argsItem);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Завершить'),
                    ),
                  ])
                : (_stackToView == 3)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: (showAnswer)
                            ? [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      //textStyle: const TextStyle(fontSize: 11),
                                      primary: const Color(0xFFf4f4f4),
                                      onPrimary: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      _scrollToTop();
                                      showAnswer = false;
                                      _stackToView = 3;
                                    });
                                  },
                                  child: const Text('Назад'),
                                ),
                              ]
                            : [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      //textStyle: const TextStyle(fontSize: 11),
                                      primary: const Color(0xFFf4f4f4),
                                      onPrimary: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      _scrollToTop();
                                      _currQuestion =
                                          getQuestion(_currQuestion);
                                      (_currQuestion == null)
                                          ? _stackToView = 2
                                          : _stackToView = 3;
                                    });
                                  },
                                  child: const Text('Пропустить'),
                                ),
                                const SizedBox(
                                  height: 30,
                                  width: 5,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      //textStyle: const TextStyle(fontSize: 11),
                                      ),
                                  onPressed: () {
                                    var mark = true;
                                    if (_currQuestion!.IdType ==
                                            CQTOneFromMany ||
                                        _currQuestion!.IdType ==
                                            CQTManyFromMany ||
                                        _currQuestion!.IdType == CQTYesNo) {
                                      mark = false;
                                    }
                                    var arr = [
                                      ...[],
                                      ..._currQuestion!.answers!
                                    ];
                                    for (TAnswer ans in arr) {
                                      if (_currQuestion!.IdType ==
                                              CQTOneFromMany ||
                                          _currQuestion!.IdType ==
                                              CQTManyFromMany ||
                                          _currQuestion!.IdType == CQTYesNo) {
                                        if (ans.answer != null) {
                                          mark = true;
                                        }
                                      } else {
                                        if (ans.answer == null) {
                                          mark = false;
                                          break;
                                        }
                                      }
                                    }
                                    if (mark) {
                                      _scrollToTop();
                                      _currQuestion?.IsMarked = mark;

                                      //if(_args.IdType == "t") {
                                      //  _refreshIndicatorKey.currentState?.show();
                                      //}else {
                                        _currQuestion = getQuestion(_currQuestion);
                                        (_currQuestion == null)
                                            ? _stackToView = 2
                                            : _stackToView = 3;
                                      //}

                                      setState(() {
                                      });
                                    }
                                  },
                                  child: const Text('Ответить'),
                                ),
                                (_args.IdType == "r") // тренажер
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _scrollToTop();
                                            showAnswer = true;
                                            _stackToView = 3;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.help_center,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 30,
                                        width: 5,
                                      ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      //textStyle: const TextStyle(fontSize: 11),
                                      primary: const Color(0xFFf4f4f4),
                                      onPrimary: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      _scrollToTop();
                                      _currQuestion = null;
                                      _stackToView = 2;
                                    });
                                  },
                                  child: const Text('Вопросы'),
                                ),
                              ])
                    : null,
        body: RefreshIndicator(
    key: _refreshIndicatorKey,
    color: Colors.white,
    backgroundColor: Colors.blue,
    strokeWidth: 4.0,
    onRefresh: () async {
    // Replace this delay with the code to be executed during refresh
    // and return a Future when code finishes execution.
    //return Future<void>.delayed(const Duration(seconds: 3));

      var isOnline = await hasNetwork(context);
      if (!isOnline) {
        return;
      }

      if(_stackToView == 3) {
        await putTest(_argsItem);
      }
      if(_stackToView == 2) {
        await syncTest(_argsItem);
      }

    },
    // Pull from top to show refresh indicator.
    child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IndexedStack(
                  index: _stackToView,
                  children: [
                    // 0 - экран ожидания
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                    // 1 - экран теста
                    Center(
                        child: Column(
                      children: <Widget>[
                        TestPreview(
                          test: _args,
                          onSelect: (value) {
                            if (value == 0) {
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                _stackToView = 2;
                              });
                            }
                          },
                        ),
                      ],
                    )),
                    // 2 - список вопросов
                    Center(
                        child: SingleChildScrollView(
                            controller: _scrollController,
                            child: QuestionList(
                      test: _args,
                      list_: list_,
                      dir: testDirectory!.path.toString(),
                      onSelect: (value) {
                        if (value == null) {
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            _currQuestion = value;
                            _stackToView = 3;
                          });
                        }
                      },
                    ))),
                    // 3 - оформление вопроса
                    Container(
                        child: (_currQuestion != null)
                            ? TQuestionPreview(
                                test: _args,
                                question: _currQuestion!,
                                dir: testDirectory!.path.toString(),
                                showAnswer: showAnswer,
                                onSelect: (value) {
                                  if (value == null) {
                                    setState(() {
                                      _currQuestion = null;
                                      _stackToView = 2;
                                    });
                                  } else {
                                    setState(() {
                                      _currQuestion = value;
                                      _stackToView = 3;
                                    });
                                  }
                                },
                              )
                            : null),
                  ],
                ))));
  }

  Future _startServer() async {
    Archive archive;
    final Directory appDir = await getApplicationDocumentsDirectory();
    final checkPath = await Directory('${appDir.path}/${_args.Id}').exists();
    if (checkPath) {
      Directory('${appDir.path}/${_args.Id}').deleteSync(recursive: true);
    }
    testDirectory =
        await Directory('${appDir.path}/${_args.Id}').create(recursive: true);
    /*
    var bytes = await File(_args.localpath!).readAsBytes();
    ByteData data = bytes.buffer.asByteData();
    List<int> content = List<int>.generate(data.lengthInBytes, (index) => 0);
    for (var i = 0; i < data.lengthInBytes; i++) {
      content[i] = data.getUint8(i);
    }
    archive = ZipDecoder().decodeBytes(content);
     */

    final inputStream = InputFileStream(_args.localpath!);
    archive = ZipDecoder().decodeBuffer(inputStream);


    await _uncompress(archive, testDirectory!);

    // СПИСОК ВОПРОСОВ
    list_ = [];

    // ЭКЗАМЕН
    if(_args.IdType == "t"){
      if(await hasNetwork(context)){
        var res = await httpAPI("close/students/mobileApp.asp",
            '{"command": "getTestTS", "id": "${_args.Id}"}', context);
        var json = res as Map<String, dynamic>;
        if(json["accessid"] == 0){
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/alert', arguments: [_argsItem, null]);
          return;
        }
        if(json["begginedAt"] == null){
          _argsItem.time = 0;
        }else{
          _argsItem.time = json["begginedAt"];
        }
        await updateItem(_argsItem);

        if(json["sections"] != null) {
          var listts = [];
          for (var sec in json["sections"]) {
            listts = [...listts, ...sec["questions"]];
          }
          for (TSection sec in _args.sections!) {
            for (TQuestion q in sec.questions!) {
              var pos = listts.indexWhere((element) => element["idU"] == q.Id);
              if(pos != -1) {
                q.IsMarked = listts[pos]["isMarked"];
                q.Active = true;
                for (TAnswer ans in q.answers!) {
                  var pos1 = listts[pos]["answers"].indexWhere((
                      element) => element["idU"] == ans.Id);
                  ans.answer = listts[pos]["answers"][pos1]["answer"];
                }
                list_.add(q);
              }else{
                q.IsMarked = null;
                q.Active = null;
              }
            }
          }
          _argsItem.jsondata = jsonEncode(_args.toMap());
          await updateItem(_argsItem);
        }
      }else{
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'Экзамен'),
                content: const Text('Можно проходить только в режиме онлайн !'),
                actions: [
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: const Text('Отмена')),
                ],
              );
            });
      }
    }

    // ПРОВЕРЯЕМ УЖЕ НАЧАТЫЙ
    //for (var e in list_) {
    //  if(e.Active ?? false) {
    //    list_.add(e);
    //  }
    //}
    if(list_.isEmpty) {
      for (TSection sec in _args.sections!) {
        if((sec.DoShuffle ?? false) == true) {
          sec.questions!.shuffle();
        }
        if ((sec.PresentQuestions ?? 0) > 0) {
          if (sec.qnum ?? false) {
            list_ = [...list_, ...sec.questions!.take(sec.PresentQuestions!)];
          }
          if (sec.qbal ?? false) {
            list_ = [...list_, ...sec.questions!.take(sec.PresentQuestions!)];
          }
          if (!(sec.qnum ?? false) && !(sec.qbal ?? false)) {
            list_ = [
              ...list_,
              ...sec.questions!.take(
                  (sec.CountQuestions! / 100 * sec.PresentQuestions!).round())
            ];
          }
        } else {
          list_ = [...list_, ...sec.questions!];
        }
      }
      for (TQuestion e in list_) {
        e.Active = true;
        if(e.DoShuffle ?? false){
          e.answers!.shuffle();
        }
      }
    }
    setState(() {
      _stackToView = 1;
    });
  }

  /// uncompressing the example archive to app directory
  Future<void> _uncompress(Archive archive, Directory dest) async {
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        List<int> data = file.content;
        File('${dest.path}/${file.name}')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('${dest.path}/${file.name}')..createSync(recursive: true);
      }
    }
  }

  /// stoping server and removing http assets
  Future _cleanup() async {
    if (testDirectory == null) return;
    final checkPath = testDirectory?.existsSync();
    if (checkPath ?? false) testDirectory?.deleteSync(recursive: true);
  }

  Future syncTest(Item item) async {
    var isOnline = await hasNetwork(context);
    if (!isOnline) {
      return;
    }
    _argsItem.sync = true;
    setState(() {});
    _argsItem.jsondata = jsonEncode(_args.toMap());
    await updateItem(_argsItem);

    Course c= await getCourse(_argsItem.courseid!);
    var res = await httpAPI(
        "close/students/sync.asp",
        '{"id": "${item.guid}", "course": "${c.guid}", "type": "TEST", "data": ' +
            jsonEncode(_args.toMap()) +
            '}',
        context) as Map<String, dynamic>;

    _args.access = [];
    _argsItem.access = null;
    if(res["access"] != null){
      _args.access = TTest.toAccess(res["access"]);
      _argsItem.access = jsonEncode(res["access"]);
    }
    _argsItem.jsondata = jsonEncode(_args.toMap());

    _argsItem.description = res["description"];

    _argsItem.history = null;
    if(res["history"] != null){
      _argsItem.history = jsonEncode(res["history"]);
    }
    _argsItem.sync = false;
    await updateItem(_argsItem);
    setState(() {});
    Navigator.of(context).pop();
  }

  Future putTest(Item item) async {
    var isOnline = await hasNetwork(context);
    if (!isOnline) {
      return;
    }
    _argsItem.jsondata = jsonEncode(_args.toMap());
    await updateItem(_argsItem);
    //await updateItem(item);
    //var json = jsonDecode(item.jsondata!);

    var res = await httpAPI(
        "close/students/sync.asp",
        '{"id": "${_argsItem.guid}", "type": "TESTTS", "data": ' +
            jsonEncode(_args.toMap()) +
            '}',
        context) as Map<String, dynamic>;

    setState(() {
      _currQuestion = getQuestion(_currQuestion);
      (_currQuestion == null)
          ? _stackToView = 2
          : _stackToView = 3;
    });
  }

}
