import 'dart:convert';

import 'package:mi_flutter/src/models/rol.dart';

Client clientFromJson(String str) => Client.fromJson(json.decode(str));

String clientToJson(Client data) => json.encode(data.toJson());

class Client {

  String id;
  String username;
  String lastname;
  String email;
  String phone;
  String password;
  String token;
  String session_token;
  String image;
  List<Rol> roles =[];
  List<Client> toList = [];



Client({
  this.id,
  this.username,
  this.lastname,
  this.email,
  this.phone,
  this.password,
  this.token,
  this.session_token,
  this.image,
  this.roles

});



factory Client.fromJson(Map<String, dynamic> json) => Client(
  id: json["id"] is int ? json["id"].toString() : json["id"],
  username: json["username"],
  lastname: json["lastname"],
  email: json["email"],
  phone: json["phone"],
  password: json["password"],
  token: json["token"],
  session_token: json["session_token"],
  image: json["image"],
  roles: json["roles"]==null ? [] : List<Rol>.from(json['roles'].map((model)=>Rol.fromJson(model)))??[],
);

Client.fromJsonList(List<dynamic> jsonList) {
  if (jsonList == null) return;
  jsonList.forEach((item) {
  Client client = Client.fromJson(item);
  toList.add(client);
  });
}


Map<String, dynamic> toJson() => {
  "id": id,
  "username": username,
  "lastname":lastname,
  "email": email,
  "phone":phone,
  "password":password,
  "token":token,
  "session_token":session_token,
  "image":image,
  "roles":roles

};
}

