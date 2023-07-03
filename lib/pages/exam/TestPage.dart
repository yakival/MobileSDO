import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
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
    super.dispose();
  }

  bool getNoAnswer() {
    list_ = [];
    for (TSection sec in _args.sections!) {
      list_ = [...list_, ...sec.questions!];
    }
    for (TQuestion q in list_) {
      if (!(q.IsMarked ?? false)) {
        return (true);
      }
    }
    return (false);
  }

  TQuestion? getQuestion(TQuestion? value) {
    list_ = [];
    for (TSection sec in _args.sections!) {
      list_ = [...list_, ...sec.questions!];
    }
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
        ),
        bottomNavigationBar: (_stackToView == 1)
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () async {
                    _argsItem.exec = true;
                    await updateItem(_argsItem);
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
                              var isOnline = await hasNetwork(context);
                              if (!isOnline) {
                                return;
                              }
                              _argsItem.sync = true;
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
                                  context);
                              _argsItem.description =
                                  (res as Map<String, dynamic>)["description"];
                              _argsItem.sync = false;
                              await updateItem(_argsItem);
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
                        _argsItem.jsondata = jsonEncode(_args.toMap());
                        await updateItem(_argsItem);
                        Navigator.of(context).pop();
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
                                      setState(() {
                                        _scrollToTop();
                                        _currQuestion?.IsMarked = mark;
                                        _currQuestion =
                                            getQuestion(_currQuestion);
                                        (_currQuestion == null)
                                            ? _stackToView = 2
                                            : _stackToView = 3;
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
        body: Padding(
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
                )));
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
    var bytes = await File(_args.localpath!).readAsBytes();
    ByteData data = bytes.buffer.asByteData();
    List<int> content = List<int>.generate(data.lengthInBytes, (index) => 0);
    for (var i = 0; i < data.lengthInBytes; i++) {
      content[i] = data.getUint8(i);
    }
    archive = ZipDecoder().decodeBytes(content);
    await _uncompress(archive, testDirectory!);

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
}
