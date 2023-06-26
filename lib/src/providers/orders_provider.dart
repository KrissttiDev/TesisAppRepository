import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mi_flutter/src/api/environment.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:http/http.dart' as http;
import 'package:mi_flutter/src/models/order.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';



class OrdersProvider{

  String _url = Environment.API_DELIVERY;
  String _api = '/api/orders';
  BuildContext context;
  Client clientDB;



  @override
  noSuchMethod(Invocation invocation) {
    // TODO: implement noSuchMethod
    return super.noSuchMethod(invocation);
  }

  Future init(BuildContext context, Client clientDB){
    this.context=context;
    this.clientDB=clientDB;
  }


  Future<List<Order>> getByStatus(String status) async{

    try {

      Uri url = Uri.https(_url, '$_api/findByStatus/$status');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.get(url, headers: headers);

     if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        //new SharedPref().logoutBD(context, clientDB);
      }
      final data = json.decode(res.body); // CATEGORIAS
      Order order = Order.fromJsonList(data);
      return order.toList;
    }
    catch(e) {
      print('Error: $e');
      return [];
    }

  }


  Future<List<Order>> getByDeliveryAndStatus(String idDelivery, String status) async{

    try {

      Uri url = Uri.https(_url, '$_api/findByDeliveryAndStatus/$idDelivery/$status');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        //new SharedPref().logoutBD(context, clientDB);
      }
      final data = json.decode(res.body); // CATEGORIAS
      Order order = Order.fromJsonList(data);
      return order.toList;
    }
    catch(e) {
      print('Error: $e');
      return [];
    }

  }



  Future<List<Order>> getByClientAndStatus(String idClient, String status) async{

    try {

      Uri url = Uri.https(_url, '$_api/findByClientAndStatus/$idClient/$status');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        //new SharedPref().logoutBD(context, clientDB);
      }
      final data = json.decode(res.body); // CATEGORIAS
      Order order = Order.fromJsonList(data);
      return order.toList;
    }
    catch(e) {
      print('Error: $e');
      return [];
    }

  }



  Future<ResponseApi> createDB(Order order) async {
    try {
      Uri url = Uri.https(_url, '$_api/create');
      String bodyParams = json.encode(order);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.post(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logoutBD(context, clientDB);
      }

      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }



  Future<ResponseApi> updateToDispachedDB(Order order) async {
    try {
      Uri url = Uri.https(_url, '$_api/updateToDispatched');
      String bodyParams = json.encode(order);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.put(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logoutBD(context, clientDB);
      }

      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }


  Future<ResponseApi> updateToTheWayDB(Order order) async {
    try {
      Uri url = Uri.https(_url, '$_api/updateToTheWay');
      String bodyParams = json.encode(order);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.put(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logoutBD(context, clientDB);
      }

      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi> updateToDeliveredDB(Order order) async {
    try {
      Uri url = Uri.https(_url, '$_api/updateToDelivered');
      String bodyParams = json.encode(order);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.put(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logoutBD(context, clientDB);
      }

      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }



  Future<ResponseApi> updateLatLngDB(Order order) async {
    try {
      Uri url = Uri.https(_url, '$_api/updateLatLng');
      String bodyParams = json.encode(order);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.put(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logoutBD(context, clientDB);
      }

      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

}






