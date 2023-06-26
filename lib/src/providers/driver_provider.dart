

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_flutter/src/api/environment.dart';
import 'package:mi_flutter/src/models/driver.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:http/http.dart'as http;


class DriverProvider {

  CollectionReference _ref;

  String _url = Environment.API_DELIVERY;
  String _api = '/api/users';

  DriverProvider(){
    _ref=FirebaseFirestore.instance.collection('Drivers');
  }


  Future<void> create(Driver driver){
    String errorMessage;
    try{
      return _ref.doc(driver.id).set(driver.toJson());

    }catch(error){
      errorMessage=error.code;
    }
    if(errorMessage != null){
      return Future.error(errorMessage);
    }

  }

  Stream<DocumentSnapshot> getByidStream(String id){
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Driver> getById(String id) async{
    DocumentSnapshot document =await _ref.doc(id).get();

    if(document.exists){

      Driver driver =Driver.fromJson(document.data());
      return driver;
    }
    return null;


  }


  Future<void>update(Map<String,dynamic> data, String id){
    return _ref.doc(id).update(data);
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