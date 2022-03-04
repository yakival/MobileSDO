class TVar {
  String? Id;
  String? IdQuestion;
  String? IdAnswer;
  String? Txt;
  int? Weight;

  TVar({
    this.Id,
    this.IdQuestion,
    this.IdAnswer,
    this.Txt,
    this.Weight,
  });

  factory TVar.fromMap(Map<String, dynamic> json) => TVar(
        Id: json["id"],
        IdQuestion: json["IdQuestion"],
        IdAnswer: json["IdAnswer"],
        Txt: json["Txt"],
        Weight: json["Weight"],
      );

  Map<String, dynamic> toMap() => {
        "id": Id,
        "IdQuestion": IdQuestion,
        "IdAnswer": IdAnswer,
        "Txt": Txt,
        "Weight": Weight,
      };
}
