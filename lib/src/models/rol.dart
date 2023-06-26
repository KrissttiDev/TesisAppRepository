import 'dart:convert';

Rol rolFromJson(String str) => Rol.fromJson(json.decode(str));

String rolToJson(Rol data) => json.encode(data.toJson());

class Rol {
  Rol({
    this.id,
    this.username,
    this.image,
    this.route,
  });

  String id;
  String username;
  String image;
  String route;

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
    id: json["id"] is int ? json['id'].toString() : json["id"],
    username: json["username"],
    image: json["image"],
    route: json["route"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "image": image,
    "route": route,
  };
}

