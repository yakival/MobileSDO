// ignore_for_file: non_constant_identifier_names

import 'package:myapp/pages/exam/class/Var.dart';

class TAnswer {
  String? Id;
  String? IdTest;
  String? IdQuestion;
  int? IdQuestionType;
  int? CountAnswers;
  bool? IsQuestionDef;
  String? Txt;
  String? IdAnswerMain;
  String? Tag;
  String? answer;
  bool? IsRight;
  String? Img;
  int? Weight;
  int? Ord;
  List<TVar>? vars;

  TAnswer(
      {this.Id,
      this.IdTest,
      this.IdQuestion,
      this.IdQuestionType,
      this.CountAnswers,
      this.IsQuestionDef,
      this.Txt,
      this.IdAnswerMain,
      this.Tag,
      this.Img,
      this.Weight,
      this.Ord,
      this.answer,
      this.IsRight,
      this.vars});

  factory TAnswer.fromMap(Map<String, dynamic> json) => TAnswer(
      Id: json["id"],
      IdTest: json["IdTest"],
      IdQuestion: json["IdQuestion"],
      IdQuestionType: json["IdQuestionType"],
      CountAnswers: json["CountAnswers"],
      IsQuestionDef: json["IsQuestionDef"],
      Txt: json["Txt"],
      IdAnswerMain: json["IdAnswerMain"],
      Tag: json["Tag"],
      Img: json["Img"],
      Weight: json["Weight"],
      Ord: json["Ord"],
      answer: json["answer"],
      IsRight: json["IsRight"],
      vars: toVar(json["vars"].toList()));

  static List<TVar> toVar(List<dynamic> sections) =>
      [for (var v in sections) TVar.fromMap(v)];

  Map<String, dynamic> toMap() => {
        "id": Id,
        "IdTest": IdTest,
        "IdQuestion": IdQuestion,
        "IdQuestionType": IdQuestionType,
        "CountAnswers": CountAnswers,
        "IsQuestionDef": IsQuestionDef,
        "Txt": Txt,
        "IdAnswerMain": IdAnswerMain,
        "Tag": Tag,
        "Img": Img,
        "Weight": Weight,
        "Ord": Ord,
        "answer": answer,
        "IsRight": IsRight,
        "vars": fromVar(vars)
      };

  static List<dynamic> fromVar(List<TVar>? sections) =>
      [for (var v in sections!) v.toMap()];
}
