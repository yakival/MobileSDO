// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unnecessary_new

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:myapp/pages/exam/class/Answer.dart';
import 'package:myapp/pages/exam/class/Test.dart';
import 'package:myapp/pages/exam/class/Var.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';

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
  TQuestionPreview({
    Key? key,
    required this.test,
    required this.question,
    required this.dir,
    required this.onSelect,
  }) : super(key: key);

  final String dir;
  final TTest test;
  final TQuestion question;
  final ValueChanged<TQuestion?> onSelect;

  @override
  State<TQuestionPreview> createState() => _TQuestionPreview();
}

class _TQuestionPreview extends State<TQuestionPreview> {
  String? radio_;
  late TextEditingController _controller;
  late bool _prepared = false;

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

  @override
  void initState() {
    super.initState();

    _prepareData();
  }

  void _prepareData() async {
    if (widget.question.IdType == CQTPicture) {
      _img ??= await getImagePoint(widget.question.answers![0].answer);
    }
    orderList = widget.question.answers!; //.map((ans) => ans).toList();

    if (widget.question.IdType == CQTOrder) {
      orderList.sort((a, b) {
        int a_ = (a.answer?.isNotEmpty != null) ? int.parse(a.answer!) : a.Ord!;
        int b_ = (b.answer?.isNotEmpty != null) ? int.parse(b.answer!) : b.Ord!;
        return a_.compareTo(b_);
      });
      var pos = 0;
      for (TAnswer ans in orderList) {
        ans.answer = pos.toString();
        pos++;
        //if (ans.Id == tempold.Id) ans.answer = newIndex.toString();
        //if (ans.Id == tempnew.Id) ans.answer = oldIndex.toString();
      }
    }
    _prepared = true;
    setState(() {});
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
    _prepareData();
    if (!_prepared) return const CircularProgressIndicator();

    switch (widget.question.IdType) {
      case CQTOneFromMany:
      case CQTManyFromMany:
      case CQTYesNo:
        if (widget.question.IdType == CQTOneFromMany) {
          for (TAnswer ans in widget.question.answers!) {
            if (ans.answer?.isNotEmpty != null) {
              radio_ = ans.Id;
              break;
            }
          }
        }
        return Column(children: <Widget>[
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
                            child: (widget.question.IdType == CQTOneFromMany)
                                ? Radio(
                                    value: e.Id!,
                                    groupValue: radio_,
                                    onChanged: (String? value) {
                                      setState(() {
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
                                    value: (e.answer?.isNotEmpty != null),
                                    onChanged: (value) {
                                      setState(() {
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
        ]);
      case CQTInputField:
        return Column(children: <Widget>[
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
                  for (TAnswer ans in widget.question.answers!) {
                    ans.answer = value;
                  }
                },
              )),
          Footer(),
        ]);
      case CQTSootv:
        return Column(children: <Widget>[
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
                                    value: e.answer,
                                    onChanged: (newValue) {
                                      setState(() {
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
        ]);
      case CQTOrder:
        return Column(children: <Widget>[
          Header(),
          DragAndDropGridView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) => Card(
              elevation: 2,
              child: LayoutBuilder(
                builder: (context, constrains) {
                  if (variableSet == 0) {
                    height = constrains.maxHeight;
                    width = constrains.maxWidth;
                    variableSet++;
                  }
                  return GridTile(
                      child: Container(
                          child: Column(children: <Widget>[
                    (orderList[index].Img!.isNotEmpty)
                        ? Container(
                            padding: const EdgeInsets.fromLTRB(
                                0.00, 15.00, 0.00, 0.00),
                            child: Image.file(
                              File('${widget.dir}/${orderList[index].Img}'),
                            ),
                            height: height,
                            width: width,
                          )
                        : Container(),
                  ])));
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
                //if (ans.Id == tempold.Id) ans.answer = newIndex.toString();
                //if (ans.Id == tempnew.Id) ans.answer = oldIndex.toString();
              }

              setState(() {});
            },
          ),
          Footer(),
        ]);
      case CQTPicture:
        return Column(children: <Widget>[
          Header(),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: GestureDetector(
                child: _img != null ? Image.memory(_img) : Container(),
                onLongPressEnd: (details) async {
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
        ]);
      case CQTLargeField:
        return Column(children: <Widget>[
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
        ]);
      case CQTManyFields:
        return Column(children: <Widget>[
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
                                              0.00, 20.00, 0.00, 0.00),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  removeAllHtmlTags(e.Txt!))))
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
                                    TextEditingController(text: e.answer),
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
        ]);
      default:
        return (Container());
    }
  }
}
