import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/pages/exam/class/Question.dart';
import 'package:myapp/pages/exam/class/Section.dart';
import 'package:myapp/pages/exam/class/Test.dart';
import 'package:path_provider/path_provider.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  TTest _args = TTest();
  Item _argsItem = Item();
  int _stackToView = 0;
  Directory? testDirectory;
  TQuestion? _currQuestion;
  List<TQuestion> list_ = [];
  late ScrollController _scrollController;

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
        if (q.IsMarked == null) {
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
          title: Text(_args.Name!),
        ),
        bottomNavigationBar: (_stackToView == 1)
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () {
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
                  onPressed: () {
                    //_handleTap(0);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Вернуться / Отменить'),
                ),
              ])
            : (_stackToView == 2)
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
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
                        children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: const Color(0xFFf4f4f4),
                                  onPrimary: Colors.black),
                              onPressed: () {
                                setState(() {
                                  _scrollToTop();
                                  _currQuestion = getQuestion(_currQuestion);
                                  (_currQuestion == null)
                                      ? _stackToView = 2
                                      : _stackToView = 3;
                                });
                              },
                              child: const Text('Пропустить'),
                            ),
                            const SizedBox(
                              height: 30,
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _scrollToTop();
                                  _currQuestion?.IsMarked = true;
                                  _currQuestion = getQuestion(_currQuestion);
                                  (_currQuestion == null)
                                      ? _stackToView = 2
                                      : _stackToView = 3;
                                });
                              },
                              child: const Text('Ответить'),
                            ),
                            const SizedBox(
                              height: 30,
                              width: 10,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
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
            child: SingleChildScrollView(
                controller: _scrollController,
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
                    )),
                    // 3 - оформление вопроса
                    Center(
                        child: (_currQuestion != null)
                            ? TQuestionPreview(
                                test: _args,
                                question: _currQuestion!,
                                dir: testDirectory!.path.toString(),
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
    var bytes = await File(_args.localpath!).readAsBytes();
    ByteData data = bytes.buffer.asByteData();
    List<int> content = List<int>.generate(data.lengthInBytes, (index) => 0);
    for (var i = 0; i < data.lengthInBytes; i++) {
      content[i] = data.getUint8(i);
    }
    archive = ZipDecoder().decodeBytes(content);
    _uncompress(archive, appDir);

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
