import 'dart:convert';

class TAccess {
  DateTime? dtfrom;
  DateTime? dtto;

  TAccess({this.dtfrom, this.dtto});

  factory TAccess.fromMap(Map<String, dynamic> json) => TAccess(
        dtfrom: (json["dtfrom"] == null)
            ? null
            : DateTime.parse(json["dtfrom"].toString()),
        dtto: (json["dtto"] == null)
            ? null
            : DateTime.parse(json["dtto"].toString()),
      );

  Map<String, dynamic> toMap() => {
        "dtfrom": dtfrom?.toIso8601String(),
        "dtto": dtto?.toIso8601String(),
      };
}
