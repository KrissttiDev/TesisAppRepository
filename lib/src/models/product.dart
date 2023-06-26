// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

import 'package:google_maps_webservice/directions.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {

  String id;
  String name;
  String description;
  String image1;
  String image2;
  String image3;
  String image4;
  String image5;
  double price;
  int id_Category;
  int quantity;
  List<Product> toList=[];




  Product({
    this.id,
    this.name,
    this.description,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
    this.image5,
    this.price,
    this.id_Category,
    this.quantity,
  });



  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"] is int ? json["id"].toString() : json["id"],
    name: json["name"],
    description: json["description"],
    image1: json["image1"],
    image2: json["image2"],
    image3: json["image3"],
    image4: json["image4"],
    image5: json["image5"],
    price: json["price"] is String ? double.parse(json["price"]) : isInteger(json["price"]) ? json["price"].toDouble(): json["price"],
    id_Category: json["id_category"] is String ? int .parse(json["id_category"] ) : json["id_category"] ,
    quantity: json["quantity"],
  );



  Product.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Product product = Product.fromJson(item);
      toList.add(product);
    });
  }




  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image1": image1,
    "image2": image2,
    "image3": image3,
    "image4": image4,
    "image5": image5,
    "price": price,
    "id_category": id_Category,
    "quantity": quantity,
  };


  static bool isInteger(num value) => value is int || value==value.roundToDouble();


}
