import 'dart:convert';

Avg avgFromJson(String str) => Avg.fromJson(json.decode(str));

String avgToJson(Avg data) => json.encode(data.toJson());

class Avg {
  Avg({
    this.avg,
  });

  double avg;

  factory Avg.fromJson(Map<String, dynamic> json) => Avg(
    avg: json["avg"]?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "avg": avg,
  };
}
