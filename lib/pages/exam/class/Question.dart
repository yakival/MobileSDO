// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unnecessary_new

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:io';

import 'package:myapp/pages/exam/class/Answer.dart';
import 'package:myapp/pages/exam/class/Test.dart';
import 'package:myapp/pages/exam/class/Var.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

class TQuestion {
  String? Id;
  String? IdTest;
  String? IdSection;
  int? IdType;
  String? RightDescription;
  String? Txt;
  String? Img;
  int? Weight;
  int? Ord;
  int? Transhoid;
  bool? IsDef;
  bool? IsMarked;
  bool? IsRight;
  bool? DoShuffle;
  int? CountAnswers;
  int? Points;
  int? iTime;
  List<TAnswer>? answers;
  List<TVar>? vars;

  TQuestion(
      {this.Id,
      this.IdTest,
      this.IdSection,
      this.CountAnswers,
      this.IdType,
      this.RightDescription,
      this.Img,
      this.Weight,
      this.Transhoid,
      this.IsDef,
      this.DoShuffle,
      this.Ord,
      this.Txt,
      this.IsMarked,
      this.IsRight,
      this.Points,
      this.iTime,
      this.answers,
      this.vars});

  factory TQuestion.fromMap(Map<String, dynamic> json) => TQuestion(
      Id: json["id"],
      IdTest: json["IdTest"],
      IdSection: json["IdSection"],
      CountAnswers: json["CountAnswers"],
      IdType: json["IdType"],
      RightDescription: json["RightDescription"],
      Img: json["Img"],
      Weight: json["Weight"],
      Transhoid: json["Transhoid"],
      IsDef: json["IsDef"],
      DoShuffle: json["DoShuffle"],
      Ord: json["Ord"],
      Txt: json["Txt"],
      IsMarked: json["IsMarked"],
      IsRight: json["IsRight"],
      iTime: json["iTime"],
      Points: json["Points"],
      answers: toAnswer(json["answers"].toList()),
      vars: toVar(json["vars"].toList()));

  static List<TAnswer> toAnswer(List<dynamic> sections) =>
      [for (var v in sections) TAnswer.fromMap(v)];

  static List<TVar> toVar(List<dynamic> sections) =>
      [for (var v in sections) TVar.fromMap(v)];

  Map<String, dynamic> toMap() => {
        "id": Id,
        "IdTest": IdTest,
        "IdSection": IdSection,
        "CountAnswers": CountAnswers,
        "IdType": IdType,
        "RightDescription": RightDescription,
        "Transhoid": Transhoid,
        "Img": Img,
        "Txt": Txt,
        "Weight": Weight,
        "Ord": Ord,
        "DoShuffle": DoShuffle,
        "IsDef": IsDef,
        "IsMarked": IsMarked,
        "IsRight": IsRight,
        "iTime": iTime,
        "Points": Points,
        "answers": fromAnswer(answers),
        "vars": fromVar(vars),
      };

  static List<dynamic> fromAnswer(List<TAnswer>? sections) =>
      [for (var v in sections!) v.toMap()];

  static List<dynamic> fromVar(List<TVar>? sections) =>
      [for (var v in sections!) v.toMap()];
}

class TQuestionPreview extends StatefulWidget {
  const TQuestionPreview({
    Key? key,
    required this.test,
    required this.question,
    required this.dir,
    required this.onSelect,
    required this.showAnswer,
  }) : super(key: key);

  final String dir;
  final TTest test;
  final TQuestion question;
  final ValueChanged<TQuestion?> onSelect;
  final bool showAnswer;

  @override
  State<TQuestionPreview> createState() => _TQuestionPreview();
}

class _TQuestionPreview extends State<TQuestionPreview> {
  String? radio_;
  late TextEditingController _controller;
  bool _prepared = false;
  bool _showAnswer = false;
  late String _currQuestion = "";
  List<DraggableGridItem> _listOfDraggableGridItem = [];

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

  // CQTOrder ////////////////////////////////////////////////////////
  int variableSet = 0;
  ScrollController? _scrollController;
  double? width;
  double? height;
  List<TAnswer> orderList = [];
  List<Widget> listOfWidgets = [];
  var _img;

  Future<Uint8List> getImagePoint(String? pos) async {
    List<int> imageData = [];
    final file = File('${widget.dir}/${widget.question.Img}');
    imageData = await file.readAsBytes();

    ui.Image image = await decodeImageFromList(Uint8List.fromList(imageData));
    var pictureRecorder = ui.PictureRecorder();
    var canvas = Canvas(pictureRecorder);
    var paint = Paint();
    paint.isAntiAlias = true;
    var src = Rect.fromLTWH(
        0.0, 0.0, image.width.toDouble(), image.height.toDouble());
    var dst = Rect.fromLTWH(
        0.0, 0.0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, src, dst, paint);

    if (pos != null) {
      var mas = pos.split(":");
      var dx = int.parse(mas[0]).toDouble();
      var dy = int.parse(mas[1]).toDouble();
      paint.color = Colors.lime;
      canvas.drawCircle(Offset(dx, dy), 15, paint);
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(
          Offset(dx, dy),
          15,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 15 / 5
            ..style = PaintingStyle.stroke);
    }

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(image.width, image.height);
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData!.buffer.asUint8List();
    return buffer;
  }
  ////////////////////////////////////////////////////////////////////

  Future<Uint8List> getImageArea(List<TAnswer> list) async {
    List<int> imageData = [];
    final file = File('${widget.dir}/${widget.question.Img}');
    imageData = await file.readAsBytes();

    ui.Image image = await decodeImageFromList(Uint8List.fromList(imageData));
    var pictureRecorder = ui.PictureRecorder();
    var canvas = Canvas(pictureRecorder);
    var paint = Paint();
    paint.isAntiAlias = true;
    var src = Rect.fromLTWH(
        0.0, 0.0, image.width.toDouble(), image.height.toDouble());
    var dst = Rect.fromLTWH(
        0.0, 0.0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, src, dst, paint);

    for (TAnswer ans in list) {
      var mas = ans.Txt!.split(";");
      var mas0 = mas[0].split(":");
      var mas1 = mas[1].split(":");
      var dx0 = int.parse(mas0[0]).toDouble();
      var dy0 = int.parse(mas0[1]).toDouble();
      var dx1 = int.parse(mas1[0]).toDouble();
      var dy1 = int.parse(mas1[1]).toDouble();
      paint.color = Colors.lime;
      paint.strokeWidth = 4;

      var dashWidth = 7;
      var dashSpace = 3;
      double start = 0;
      final space = (dashSpace + dashWidth);

      start = dx0;
      while (start < (dx1)) {
        canvas.drawLine(
            Offset(start, dy0), Offset(start + dashWidth, dy0), paint);
        canvas.drawLine(
            Offset(start, dy1), Offset(start + dashWidth, dy1), paint);
        start += space;
      }
      start = dy0;
      while (start < (dy1)) {
        canvas.drawLine(
            Offset(dx0, start), Offset(dx0, start + dashWidth), paint);
        canvas.drawLine(
            Offset(dx1, start), Offset(dx1, start + dashWidth), paint);
        start += space;
      }
    }

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(image.width, image.height);
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData!.buffer.asUint8List();
    return buffer;
  }
  ////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _prepared = false;
    _prepareData();
  }

  List<TAnswer> shuffle(List<TAnswer> items) {
    var random = new Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  void _prepareData() async {
    if (widget.question.IdType == CQTPicture) {
      _img = null;
      if (widget.showAnswer) {
        _img ??= await getImageArea(widget.question.answers!);
      } else {
        _img ??= await getImagePoint(widget.question.answers![0].answer);
      }
    }
    orderList = widget.question.answers!; //.map((ans) => ans).toList();

    if (widget.question.IdType == CQTOrder) {
      if (widget.showAnswer) {
        orderList.sort((p1, p2) {
          return Comparable.compare(p1.Ord!, p2.Ord!);
        });
      } else {
        if (orderList[0].answer?.isNotEmpty == null) {
          orderList = shuffle(orderList);
          var pos = 0;
          for (TAnswer ans in orderList) {
            ans.answer = pos.toString();
            pos++;
          }
        } else {
          orderList.sort((p1, p2) {
            return Comparable.compare(p1.answer!, p2.answer!);
          });
        }
      }
      _prepareOrderList();
    }
    _prepared = true;
    setState(() {});
  }

  void _prepareOrderList() async {
    _listOfDraggableGridItem = List.generate(orderList.length, (index) =>
        DraggableGridItem(child: (orderList[index].Img!.isNotEmpty)
            ? Card(child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.padding_small,
            vertical: Dimens.padding_small,
          ),
          child: Image.file(
            File('${widget.dir}/${orderList[index].Img}'),
            fit: BoxFit.cover,
          ),
          //width: width,
          //height: height,
        ))
            : Card(
            clipBehavior: Clip.hardEdge,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.padding_small,
                vertical: Dimens.padding_small,
              ),
              child: Center(
                  child: Text(
                      removeAllHtmlTags(orderList[index].Txt!) +
                          " (№" +
                          (index + 1).toString() +
                          ")")),
              //width: width,
              //height: height,
            )), isDraggable: true)
    );
  }

  void _handleTap(value) {
    widget.onSelect(value);
  }

  Widget Header() {
    return Column(children: <Widget>[
      (widget.question.Txt!.replaceAll("<p><br></p>", "").isNotEmpty)
          ? Text(removeAllHtmlTags(widget.question.Txt!))
          : Container(),
      ((widget.question.Img!.isNotEmpty) &&
              (widget.question.IdType != CQTPicture))
          ? Image.file(
              File('${widget.dir}/${widget.question.Img}'),
              width: 100.00,
            )
          : Container(),
      Container(
        padding: const EdgeInsets.all(10.00),
      ),
    ]);
  }

  Widget Footer() {
    return Column(children: <Widget>[
      Container(
        padding: const EdgeInsets.all(10.0),
      ),
    ]);
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    if (_showAnswer != widget.showAnswer ||
        _currQuestion != widget.question.Id) {
      _showAnswer = widget.showAnswer;
      _currQuestion = widget.question.Id!;
      _prepared = false;
    }
    if (!_prepared) Future.delayed(Duration.zero, () => _prepareData());
    if (!_prepared) return const CircularProgressIndicator();

    switch (widget.question.IdType) {
      case CQTOneFromMany:
      case CQTManyFromMany:
      case CQTYesNo:
        if (widget.question.IdType == CQTOneFromMany ||
            widget.question.IdType == CQTYesNo) {
          radio_ = null;
          for (TAnswer ans in widget.question.answers!) {
            if (widget.showAnswer) {
              if ((ans.Weight ?? 0) > 0) {
                radio_ = ans.Id;
                break;
              }
            } else {
              if (ans.answer?.isNotEmpty != null) {
                radio_ = ans.Id;
                break;
              }
            }
          }
        }
        return SingleChildScrollView(
            controller: _scrollController,
            child: Column(children: <Widget>[
          Header(),
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(40.0),
              1: MaxColumnWidth(
                  FixedColumnWidth(0.0), FractionColumnWidth(1.0)),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: widget.question.answers!
                .map((e) => TableRow(
                      children: [
                        TableCell(
                            child: (widget.question.IdType == CQTOneFromMany) ||
                                    (widget.question.IdType == CQTYesNo)
                                ? Radio(
                                    value: e.Id!,
                                    groupValue: radio_,
                                    onChanged: (String? value) {
                                      setState(() {
                                        if (widget.showAnswer) {
                                          return;
                                        }
                                        radio_ = value!;
                                        for (TAnswer ans
                                            in widget.question.answers!) {
                                          if (ans.Id == radio_) {
                                            ans.answer = "1";
                                          } else {
                                            ans.answer = null;
                                          }
                                        }
                                      });
                                    },
                                  )
                                : Checkbox(
                                    value: (widget.showAnswer)
                                        ? ((e.Weight ?? 0) > 0)
                                        : (e.answer?.isNotEmpty != null),
                                    onChanged: (value) {
                                      setState(() {
                                        if (widget.showAnswer) {
                                          return;
                                        }
                                        (value!)
                                            ? e.answer = "1"
                                            : e.answer = null;
                                      });
                                    },
                                  )),
                        TableCell(
                          child: Column(children: <Widget>[
                            (e.Txt!.replaceAll("<p><br></p>", "").isNotEmpty)
                                ? Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.00, 15.00, 0.00, 0.00),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(removeAllHtmlTags(e.Txt!))))
                                : Container(),
                            (e.Img!.isNotEmpty)
                                ? Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.00, 15.00, 0.00, 0.00),
                                    child: Image.file(
                                      File('${widget.dir}/${e.Img}'),
                                    ))
                                : Container(),
                          ]),
                        ),
                      ],
                    ))
                .toList(),
          ),
          Footer(),
        ]));
      case CQTInputField:
        var ans_ = "";
        if (widget.showAnswer) {
          for (TAnswer ans in widget.question.answers!) {
            if ((ans.Weight ?? 0) > 0) {
              ans_ += '<li>${ans.Txt}</li>';
              break;
            }
          }
        }
        ans_ = "<ul>" + ans_ + "</ul>";

        return SingleChildScrollView(
    controller: _scrollController,
    child: Column(children: <Widget>[
          Header(),
          Container(
              padding: const EdgeInsets.all(20.00),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                    text: widget.question.answers?.first.answer),
                onSubmitted: (value) {
                  if (widget.showAnswer) {
                    return;
                  }
                  for (TAnswer ans in widget.question.answers!) {
                    ans.answer = value;
                  }
                },
              )),
          (widget.showAnswer) ? Html(data: ans_) : Container(),
          Footer(),
        ]));
      case CQTSootv:
        return SingleChildScrollView(
    controller: _scrollController,
    child: Column(children: <Widget>[
          Header(),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: widget.question.answers!
                .map((e) => TableRow(
                      children: [
                        TableCell(
                            child: Container(
                                width:
                                    (MediaQuery.of(context).size.width - 150) /
                                        2,
                                child: Column(children: <Widget>[
                                  (e.Txt!
                                          .replaceAll("<p><br></p>", "")
                                          .isNotEmpty)
                                      ? Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.00, 15.00, 0.00, 0.00),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                removeAllHtmlTags(e.Txt!),
                                              )))
                                      : Container(),
                                  (e.Img!.isNotEmpty)
                                      ? Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.00, 15.00, 0.00, 0.00),
                                          child: Image.file(
                                            File('${widget.dir}/${e.Img}'),
                                          ))
                                      : Container(),
                                ]))),
                        TableCell(
                            child: Container(
                          width: (MediaQuery.of(context).size.width - 150) / 2,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: DropdownButton(
                                    value: (widget.showAnswer)
                                        ? e.vars![0].Id
                                        : e.answer,
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (widget.showAnswer) {
                                          return;
                                        }
                                        e.answer = newValue as String?;
                                      });
                                    },
                                    items: widget.question.vars
                                        ?.map((v) => DropdownMenuItem(
                                            child:
                                                Text(removeAllHtmlTags(v.Txt!)),
                                            value: v.Id))
                                        .toList())),
                          ),
                        )),
                      ],
                    ))
                .toList(),
          ),
          Footer(),
        ]));
      case CQTOrder:
        return SafeArea(child: DraggableGridViewBuilder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 3),
            ),
            children: _listOfDraggableGridItem,
            isOnlyLongPress: false,
            dragCompletion: (List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
              final tempold = orderList[beforeIndex];
              final tempnew = orderList[afterIndex];
              orderList[beforeIndex] = tempnew; orderList[beforeIndex].answer = beforeIndex.toString();
              orderList[afterIndex] = tempold; orderList[afterIndex].answer = afterIndex.toString();

              for (TAnswer ans in orderList) {
                widget.question.answers!.firstWhere((sl) => sl.Id == ans.Id).answer = ans.answer;
              }
              _prepareOrderList();
              setState(() {});
            },
          dragFeedback: (List<DraggableGridItem> list, int index) {
            return Container(
              child: list[index].child,
              width: 200,
              height: 150,
            );
          },
          dragPlaceHolder: (List<DraggableGridItem> list, int index) {
            return PlaceHolderWidget(
              child: Container(
                color: Colors.white,
              ),
            );
          },
          ));
          /*
          DraggableGridViewBuilder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height / 3),
            ),
            itemBuilder: (context, index) => Card(
              elevation: 2,
              child: LayoutBuilder(
                builder: (context, constrains) {
                  if (variableSet == 0) {
                    height = constrains.minHeight;
                    width = constrains.minWidth;
                    variableSet++;
                  }
                  return (orderList[index].Img!.isNotEmpty)
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(
                              0.00, 15.00, 0.00, 0.00),
                          child: Image.file(
                            File('${widget.dir}/${orderList[index].Img}'),
                          ),
                          width: width,
                          height: height,
                        )
                      : Container(
                          padding: const EdgeInsets.fromLTRB(
                              0.00, 15.00, 0.00, 0.00),
                          child: Center(
                              child: Text(
                                  removeAllHtmlTags(orderList[index].Txt!) +
                                      " (№" +
                                      (index + 1).toString() +
                                      ")")),
                          width: width,
                          height: height,
                        );
                },
              ),
            ),
            itemCount: orderList.length,
            onWillAccept: (oldIndex, newIndex) {
              //if (widget.question.answers![newIndex] == "something") {
              //  return false;
              //}
              return true;
            },
            onReorder: (oldIndex, newIndex) {
              final tempold = orderList[oldIndex];
              final tempnew = orderList[newIndex];
              orderList[oldIndex] = tempnew;
              orderList[newIndex] = tempold;

              var pos = 0;
              for (TAnswer ans in widget.question.answers!) {
                ans.answer = pos.toString();
                pos++;
              }

              setState(() {});
            },
          );
           */
        //  Footer(),
        //]);
      case CQTPicture:
        return SingleChildScrollView(
    controller: _scrollController,
    child: Column(children: <Widget>[
          Header(),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: GestureDetector(
                child: _img != null ? Image.memory(_img) : Container(),
                //onLongPressEnd:
                onLongPressEnd: (details) async {
                  if (widget.showAnswer) {
                    return;
                  }
                  String val = details.localPosition.dx.toInt().toString() +
                      ":" +
                      details.localPosition.dy.toInt().toString();
                  for (TAnswer ans in widget.question.answers!) {
                    ans.answer = val;
                  }
                  _img = await getImagePoint(val);
                  setState(() {});
                },
              )),
        ]));
      case CQTLargeField:
        return SingleChildScrollView(
    controller: _scrollController,
    child: Column(children: <Widget>[
          Header(),
          Container(
              padding: const EdgeInsets.all(20.00),
              child: TextField(
                  minLines:
                      8, // any number you need (It works as the rows for the textarea)
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(
                      text: widget.question.answers?.first.answer),
                  onSubmitted: (value) {
                    for (TAnswer ans in widget.question.answers!) {
                      ans.answer = value;
                    }
                  },
                  onChanged: (value) {
                    for (TAnswer ans in widget.question.answers!) {
                      ans.answer = value;
                    }
                  })),
          Footer(),
        ]));
      case CQTManyFields:
        return SingleChildScrollView(
    controller: _scrollController,
    child: Column(children: <Widget>[
          Header(),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: widget.question.answers!
                .map((e) => TableRow(
                      children: [
                        TableCell(
                            child: Container(
                                width:
                                    (MediaQuery.of(context).size.width - 150) /
                                        2,
                                child: Column(children: <Widget>[
                                  (e.Txt!
                                          .replaceAll("<p><br></p>", "")
                                          .replaceAll("&nbsp;", "")
                                          .isNotEmpty)
                                      ? Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.00, 20.00, 0.00, 0.00),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Html(data: e.Txt!)))
                                      : Container(),
                                  (e.Img!.isNotEmpty)
                                      ? Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.00, 15.00, 0.00, 0.00),
                                          child: Image.file(
                                            File('${widget.dir}/${e.Img}'),
                                          ))
                                      : Container(),
                                ]))),
                        TableCell(
                            child: Container(
                          width: (MediaQuery.of(context).size.width - 150) / 2,
                          child: Container(
                              padding: const EdgeInsets.all(5.00),
                              child: TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                controller:
                                    TextEditingController(
                                        text: e.answer,
                                    ),
                                onSubmitted: (value) {
                                  setState(() {
                                    e.answer = value;
                                  });
                                },
                              )),
                        )),
                      ],
                    ))
                .toList(),
          ),
          Footer(),
        ]));
      case CQTShortFields:
        List<String> tags = [];
        String txt = widget.question.answers![0].Txt! +
            "<txt id='0' ></txt>" + widget.question.answers![0].Tag!;
        tags.add("txt");

        CustomRenderMatcher txtMatcher() => (context) => context.tree.element?.localName == 'txt';
        CustomRenderMatcher imgMatcher() => (context) => context.tree.element?.localName == 'img';

        return
          SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(children: <Widget>[
              Header(),
          Html(
            data: txt,
            tagsList: Html.tags..addAll(tags),
            customRenders: {
              txtMatcher(): CustomRender.widget(widget: (context, buildChildren) {
                var num = int.parse(context.tree.elementId);
                var q = "" + widget.question.vars![0].Txt!;
                var a = "" + ((widget.question.answers![0].answer != null)?widget.question.answers![0].answer!:"");
                //myController[num - 1].value = TextEditingValue(text: (widget.showAnswer)?q:a);
                return Container(
                    padding: const EdgeInsets.all(5.00),
                    child:
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: //myController[num - 1],
                      TextEditingController(text: (widget.showAnswer)?q:a),
                      //autofocus: (num ==1)?true:false,
                      //focusNode: myFocusNode[num - 1],
                      //textInputAction: TextInputAction.next,
                      //onEditingComplete: _node.nextFocus,
                      onFieldSubmitted: (value) {
                        if(!widget.showAnswer) {
                          widget.question.answers![0].answer = value;
                        }
                      },
                    ));
              }),
              imgMatcher(): CustomRender.widget(widget: (context, buildChildren) {
                return Container(
                    padding: const EdgeInsets.fromLTRB(
                        0.00, 5.00, 0.00, 0.00),
                    child: Image.file(
                      File('${widget.dir}/${widget.question.answers![0].Img}'),
                    ));
              }),
            },
          )
          ]));
      default:
        return (Container());
    }
  }


}
class Dimens {
  // Padding
  static const padding_small = 4.0;
  static const padding_normal = 8.0;
}