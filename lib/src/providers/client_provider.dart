

import 'dart:convert';
import 'dart:io';



import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_flutter/src/api/environment.dart';

import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/driver.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:path/path.dart';


class ClientProvider {
  BuildContext context;




  CollectionReference _ref;
  String _url = Environment.API_DELIVERY;
  String _api = '/api/users';
  Client clientDB;

  /*String session_token;*/






  ClientProvider(){
    _ref=FirebaseFirestore.instance.collection('Clients');
  }

  /*Future init(BuildContext context, {Client clientDB}) {
    this.context = context;
    this.clientDB = clientDB;
  }*/





  //CONEXION A LA BASE DE DATOS



  Future<Client> getByIdDB(String id,Client clientTok)async{


    try{
      Uri url = Uri.https(_url, '$_api/findById/$id');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientTok.session_token
      };
      final res = await http.get(url,headers: headers);
      if(res.statusCode==401){ //No Authorized
        Fluttertoast.showToast(msg: 'Tu sesión expiró');
        new SharedPref().logoutBD(context,clientTok);


      }
      final data = json.decode(res.body);
      Client clientDB =Client.fromJson(data);
      print('Esta es una pruebaaaa = >${clientDB.username}');
      return clientDB;
    }
    catch(e){
      print('Error : =>$e');
      return null;

    }
  }


  Future<List<Client>> getDeliveryMen() async {
    try {
      Uri url = Uri.https(_url, '$_api/findDeliveryMan');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) { // NO AUTORIZADO
        Fluttertoast.showToast(msg: 'Tu sesion expiro');
        new SharedPref().logoutBD(context, clientDB);
      }

      final data = json.decode(res.body);
      if(data!=null) {
        print('hay datos');
      }else {print('NO hay datos');}
      Client user = Client.fromJsonList(data);
      return user.toList;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }


  Future<List<String>> getAdminsNotificationTokens() async {
    try {
      Uri url = Uri.https(_url, '$_api/getAdminsNotificationToken');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) { // NO AUTORIZADO
        Fluttertoast.showToast(msg: 'Tu sesion expiro');
        new SharedPref().logoutBD(context, clientDB);
      }

      final data = json.decode(res.body);
      if(data!=null) {
        print('hay datos');
      }else {print('NO hay datos');}
      final tokens=List<String>.from(data);
      return tokens;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }







  Future<ResponseApi>createDB(Client client) async {

    print('============holiiiiii');

    try {
      Uri url = Uri.https(_url, '$_api/create');
      String bodyParams = json.encode(client);
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


  Future<ResponseApi>updateNotificationTokenDB(Client clientDB, String token) async {
    print('================================================================');
    print(token);
    print('================================================================');
    try {
      Uri url = Uri.https(_url, '$_api/updateNotificationToken');
      String bodyParams = json.encode({
        'id':clientDB.id,
        'token':token
      });
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };

      final res = await http.put(url, headers: headers, body: bodyParams);
      if (res.statusCode == 401) { // NO AUTORIZADO
        Fluttertoast.showToast(msg: 'Tu sesion expiro');
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

  Future<ResponseApi>logoutDB(String idUser) async {


    try {
      Uri url = Uri.https(_url, '$_api/logout');
      String bodyParams = json.encode({
        'id':idUser
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




  Future<Stream> createWithImageDB(Client clientDB, File image) async {
    try {
      Uri url = Uri.https(_url, '$_api/create');
      final request = http.MultipartRequest('POST', url);

      if (image != null) {
        request.files.add(http.MultipartFile(
            'image',
            http.ByteStream(image.openRead().cast()),
            await image.length(),
            filename: basename(image.path)
        ));
      }

      request.fields['username'] = json.encode(clientDB);
      final response = await request.send(); // ENVIARA LA PETICION
      return response.stream.transform(utf8.decoder);
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }




  Future<Stream> updateDB(Client clientDB,File image)async {
    print(clientDB.lastname);
    print(clientDB.session_token);

    try{
      Uri url = Uri.https(_url, '$_api/update');
      final request=http.MultipartRequest('PUT',url);
      request.headers['Authorization'] = clientDB.session_token; //seguridad
      if(image!=null){
        request.files.add(http.MultipartFile(
            'image',
            http.ByteStream(image.openRead().cast()),
            await image.length(),
            filename: basename(image.path)
        ));
      }

      request.fields['user']=json.encode(clientDB);
      final response =await request.send(); //ENVIARA LA PETICION
      if(response.statusCode==401){
        Fluttertoast.showToast(msg: 'Tu sesión expiró');
        //new SharedPref().logoutBD(context,clientDB);
      }

      return response.stream.transform(utf8.decoder);

    }
    catch(e){
      print('Error: $e');
      return null;

    }

  }






//========================================================================
//CONEXION CON FIREBASE
  Future<void> create(Client client){
    String errorMessage;
    try{
      return _ref.doc(client.id).set(client.toJson());

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

  Future<Client> getById(String id) async{
    DocumentSnapshot document =await _ref.doc(id).get();

    if(document.exists){
      Client client =Client.fromJson(document.data());
     return client;

    }
    return null;



  }


  Future<void>update(Map<String,dynamic> data, String id){
    return _ref.doc(id).update(data);
  }






}