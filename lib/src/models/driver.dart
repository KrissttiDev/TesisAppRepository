
import 'dart:convert';

import 'package:mi_flutter/src/models/rol.dart';



Driver driverFromJson(String str) => Driver.fromJson(json.decode(str));

String driverToJson(Driver data) => json.encode(data.toJson());

class Driver {

  String id;
  String username;
  String lastname;
  String email;
  String phone;
  String password;
  String plate; //-----parametro a bd aparte
  String token;
  String session_token;
  String image;
  String status;   // parametro a bd aparte
  bool activated; //--------parametro a bd aparte
  List<Rol> roles =[];


  Driver({
    this.id,
    this.username,
    this.lastname,
    this.email,
    this.phone,
    this.password,
    this.plate,
    this.token,
    this.session_token,
    this.image,
    this.status,
    this.activated,
    this.roles



  });



  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    username: json["username"],
    lastname: json["lastname"],
    email: json["email"],
    phone: json["phone"],
    password: json["password"],
    plate: json["plate"],
    token: json["token"],
    session_token: json["session_token"],
    image:json["image"],
    status: json["status"],
    activated: json["activated"],
    roles: json["roles"]==null ? [] : List<Rol>.from(json['roles'].map((model)=>Rol.fromJson(model)))??[],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "lastname":lastname,
    "email": email,
    "phone":phone,
    "password":password,
    "plate": plate,
    "token":token,
    "session_token":session_token,
    "image":image,
    "status":status,
    "activated": activated,
    "roles":roles
  };
}
