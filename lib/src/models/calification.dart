import 'dart:convert';

Calification calificationFromJson(String str) => Calification.fromJson(json.decode(str));

String calificationToJson(Calification data) => json.encode(data.toJson());

class Calification {

  Calification({
     this.idUser,
     this.calification,
  });

  String idUser;
  double calification;

  factory Calification.fromJson(Map<String, dynamic> json) => Calification(
    idUser: json["id_user"]is int ? json["id_user"].toString() : json["id_user"],
    calification: json["calification"]?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "calification": calification,
  };
}
