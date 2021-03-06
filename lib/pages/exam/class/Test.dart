// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/pages/exam/class/Question.dart';
import 'package:myapp/pages/exam/class/Section.dart';

class TTest {
  String? Id;
  String? Name;
  bool? IsOk;
  String? IdCreator;
  int? PasScore;
  String? IdCourse;
  String? IdType;
  String? Type;
  int? TimeToTest;
  int? iQTime;
  bool? isFwdOnly;
  bool? DoShuffle;
  String? idModule;
  String? Descr;
  int? CountSections;
  int? CountQuestions;
  int? TotScore;
  int? MaxScore;
  List<TSection>? sections;
  String? localpath;

  TTest(
      {this.Id,
      this.Name,
      this.IsOk,
      this.IdCreator,
      this.PasScore,
      this.IdCourse,
      this.IdType,
      this.Type,
      this.TimeToTest,
      this.iQTime,
      this.isFwdOnly,
      this.DoShuffle,
      this.idModule,
      this.Descr,
      this.CountSections,
      this.CountQuestions,
      this.TotScore,
      this.MaxScore,
      this.sections,
      this.localpath});

  factory TTest.fromMap(Map<String, dynamic> json) => TTest(
        Id: json["id"],
        Name: json["Name"],
        IsOk: json["IsOk"],
        IdCreator: json["IdCreator"],
        PasScore: json["PasScore"],
        IdCourse: json["IdCourse"],
        IdType: json["IdType"],
        Type: json["type"],
        TimeToTest: json["TimeToTest"],
        iQTime: json["iQTime"],
        isFwdOnly: json["isFwdOnly"],
        DoShuffle: json["DoShuffle"],
        idModule: json["idModule"],
        Descr: json["Descr"],
        CountSections: json["CountSections"],
        CountQuestions: json["CountQuestions"],
        TotScore: json["TotScore"],
        MaxScore: json["MaxScore"],
        sections: toSection(json["sections"].toList()),
      );

  static List<TSection> toSection(List<dynamic> sections) =>
      [for (var v in sections) TSection.fromMap(v)];

  Map<String, dynamic> toMap() => {
        "id": Id,
        "Name": Name,
        "IsOk": IsOk,
        "IdCreator": IdCreator,
        "PasScore": PasScore,
        "IdCourse": IdCourse,
        "IdType": IdType,
        "type": Type,
        "TimeToTest": TimeToTest,
        "iQTime": iQTime,
        "isFwdOnly": isFwdOnly,
        "DoShuffle": DoShuffle,
        "idModule": idModule,
        "Descr": Descr,
        "CountSections": CountSections,
        "CountQuestions": CountQuestions,
        "TotScore": TotScore,
        "MaxScore": MaxScore,
        "sections": fromSection(sections)
      };

  static List<dynamic> fromSection(List<TSection>? sections) =>
      [for (var v in sections!) v.toMap()];
}

class TestPreview extends StatelessWidget {
  TestPreview({
    Key? key,
    required this.test,
    required this.onSelect,
  }) : super(key: key);

  final TTest test;
  final ValueChanged<int> onSelect;

  void _handleTap(value) {
    onSelect(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
            1: FixedColumnWidth(20),
            2: IntrinsicColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                const TableCell(
                  child: Text(
                    "????????????????",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(),
                TableCell(
                  child: Text(
                    test.Descr!,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            /*
            TableRow(
              children: <Widget>[
                const TableCell(
                  child: Text(
                    "?????????? ???? ????????",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(),
                TableCell(
                  child: Text(
                    (test.TimeToTest! > 0)
                        ? test.TimeToTest.toString() + " ??????????"
                        : "???? ????????????????????",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            TableRow(
              children: <Widget>[
                const TableCell(
                  child: Text(
                    "?????????? ???? ????????????",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(),
                TableCell(
                  child: Text(
                    (test.iQTime! > 0)
                        ? test.iQTime.toString() + " ????????????"
                        : "???? ????????????????????",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            */
            TableRow(
              children: <Widget>[
                const TableCell(
                  child: Text(
                    "",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(),
                TableCell(
                    child: Container(
                  padding: const EdgeInsets.fromLTRB(0.00, 20.00, 0.00, 0.00),
                  child: const Text(
                    '''?? ???????? ???????????????????????? ???????????????? ?????????? ?? ?????????????? ???????????? ????????????????.
???????? ??????????????????????????, ?????????????? ???????????? ????????????????????. ?? ?????????????????????? ???????????????? ?????????? ?????????? ??????????????????.
?????? ?????????????????? ?????????????? ?????????????????????? ???? ?????????????? ????????????????.''',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
        ),
      ],
    );
  }
}

class QuestionList extends StatelessWidget {
  QuestionList({
    Key? key,
    required this.test,
    required this.dir,
    required this.onSelect,
  }) : super(key: key);

  final String dir;
  final TTest test;
  final ValueChanged<TQuestion?> onSelect;
  List<TQuestion> list_ = [];

  void _handleTap(value) {
    onSelect(value);
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text("?????????????? ??????????"),
        _createDataTable(context),
        Container(
          padding: const EdgeInsets.all(20.0),
        ),
      ],
    );
  }

  DataTable _createDataTable(BuildContext context) {
    return DataTable(
        columnSpacing: 5.00,
        dataRowHeight: kMinInteractiveDimension * 1.6,
        columns: _createColumns(),
        rows: _createRows(context));
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        label: Text('#'),
        numeric: true,
      ),
      const DataColumn(
        label: Text('????????????'),
        numeric: false,
      ),
      const DataColumn(
        label: Text('????????????????'),
        numeric: false,
      )
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    list_ = [];
    for (TSection sec in test.sections!) {
      list_ = [...list_, ...sec.questions!];
    }
    int i = 0;
    return list_.map((book) {
      i++;
      return DataRow(
        cells: [
          DataCell(Container(
              width: 10, //SET width
              child: Align(
                  alignment: Alignment.centerLeft, child: Text(i.toString())))),
          DataCell(
            Container(
                width: MediaQuery.of(context).size.width - 150,
                child: (book.Txt!.replaceAll("<p><br></p>", "").isEmpty)
                    ? Image.file(
                        File('$dir/${book.Img}'),
                        width: 100.00,
                      )
                    : Text(removeAllHtmlTags(book.Txt!))),
            onTap: () {
              _handleTap(book);
            },
          ),
          DataCell(Container(
              width: 50, //SET width
              child: (!(book.IsMarked ?? false))
                  ? IconButton(
                      icon: Icon(Icons.warning_amber_outlined,
                          color: Colors.yellow[900]),
                      onPressed: null,
                    )
                  : const Text(""))),
        ],
      );
    }).toList();
  }
}
