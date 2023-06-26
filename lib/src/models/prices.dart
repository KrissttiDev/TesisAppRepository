// To parse this JSON data, do
//
//     final prices = pricesFromJson(jsonString);

import 'dart:convert';

Prices pricesFromJson(String str) => Prices.fromJson(json.decode(str));

String pricesToJson(Prices data) => json.encode(data.toJson());

class Prices {
  Prices({
    this.km,
    this.min,
    this.minValue,
  });

  double km;
  double min;
  double minValue;

  factory Prices.fromJson(Map<String, dynamic> json) => Prices(
    km: json["km"],
    min: json["min"],
    minValue: json["minValue"],
  );

  Map<String, dynamic> toJson() => {
    "km": km,
    "min": min,
    "minValue": minValue,
  };
}