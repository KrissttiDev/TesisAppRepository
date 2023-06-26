import 'dart:convert';

UserN clientFromJson(String str) => UserN.fromJson(json.decode(str));

String clientToJson(UserN data) => json.encode(data.toJson());

class UserN {

  String id;
  String username;
  String lastname;
  String email;
  String phone;
  String password;
  String token;
  String image;


  UserN({
    this.id,
    this.username,
    this.lastname,
    this.email,
    this.phone,
    this.password,
    this.token,
    this.image
  });



  factory UserN.fromJson(Map<String, dynamic> json) => UserN(
    id: json["id"],
    username: json["username"],
    lastname: json["lastname"],
    email: json["email"],
    phone: json["phone"],
    password: json["password"],
    token: json["token"],
    image: json["image"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "lastname":lastname,
    "email": email,
    "phone":phone,
    "password":password,
    "token":token,
    "image":image

  };
}

