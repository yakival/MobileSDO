import 'package:myapp/pages/exam/class/Question.dart';

class TSection {
  String? Id;
  String? IdTest;
  String? Name;
  int? PresentQuestions;
  String? DoShuffle;
  int? Ord;
  bool? qbal;
  bool? qnum;
  int? CountQuestions;
  int? TotScore;
  int? MaxScore;
  List<TQuestion>? questions;

  TSection(
      {this.Id,
      this.IdTest,
      this.Name,
      this.PresentQuestions,
      this.DoShuffle,
      this.Ord,
      this.qbal,
      this.qnum,
      this.CountQuestions,
      this.TotScore,
      this.MaxScore,
      this.questions});

  factory TSection.fromMap(Map<String, dynamic> json) => TSection(
      Id: json["id"],
      IdTest: json["IdTest"],
      Name: json["Name"],
      PresentQuestions: json["PresentQuestions"],
      DoShuffle: json["DoShuffle"],
      Ord: json["Ord"],
      qbal: json["qbal"],
      qnum: json["qnum"],
      CountQuestions: json["CountQuestions"],
      TotScore: json["TotScore"],
      MaxScore: json["MaxScore"],
      questions: toQuestion(json["questions"].toList()));

  static List<TQuestion> toQuestion(List<dynamic> sections) =>
      [for (var v in sections) TQuestion.fromMap(v)];

  Map<String, dynamic> toMap() => {
        "id": Id,
        "": IdTest,
        "Name": Name,
        "PresentQuestions": PresentQuestions,
        "DoShuffle": DoShuffle,
        "Ord": Ord,
        "qbal": qbal,
        "qnum": qnum,
        "CountQuestions": CountQuestions,
        "TotScope": TotScore,
        "MaxScope": MaxScore,
        "questions": fromQuestion(questions),
      };

  static List<dynamic> fromQuestion(List<TQuestion>? sections) =>
      [for (var v in sections!) v.toMap()];
}
