

import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:mi_flutter/src/api/environment.dart';

import 'package:mi_flutter/src/models/driver.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:http/http.dart'as http;


class DriverDProvider {
  BuildContext context;


  String _url = Environment.API_DELIVERY;
  String _api = '/api/users';
  Driver driverDB;
  Future init(BuildContext context, {Driver driverDB}) {
    this.context = context;
    this.driverDB = driverDB;
  }





  //--------------------------------------conexion a bd
  Future<ResponseApi>createDB(Driver driver) async {

    print('============holiiiiii');

    try {
      Uri url = Uri.https(_url, '$_api/create');
      String bodyParams = json.encode(driver);
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };

      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi> loginDB(String email,String password)async{
    try {
      Uri url = Uri.https(_url, '$_api/login');
      String bodyParams = json.encode({
        'email':email,
        'password':password
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };

      final res = await http.post(url, headers: headers, body: bodyParams);
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