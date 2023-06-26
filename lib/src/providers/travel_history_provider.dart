import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_flutter/src/api/environment.dart';
import 'package:mi_flutter/src/models/avg.dart';
import 'package:mi_flutter/src/models/calification.dart';
import 'package:mi_flutter/src/models/response_api.dart';




import 'package:mi_flutter/src/models/travel_history.dart';
import 'package:mi_flutter/src/models/driver.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';

class TravelHistoryProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/history';


  CollectionReference _ref;

  TravelHistoryProvider() {
    _ref = FirebaseFirestore.instance.collection('TravelHistory');
  }

  Future<String> create(TravelHistory travelHistory) async {
    String errorMessage;

    try {
      String id = _ref.doc().id;
      travelHistory.id = id;

      await _ref.doc(travelHistory.id).set(travelHistory.toJson()); // ALMACENAMOS LA INFORMACION
      return id;
    } catch(error) {
      errorMessage = error.code;
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }
  }

  Future<List<TravelHistory>> getByIdClient(String idClient) async {
    QuerySnapshot querySnapshot = await _ref.where('idClient', isEqualTo: idClient).orderBy('timestamp', descending: true).get();
    //List<Map<String, dynamic>> allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(allData);


    List<TravelHistory> travelHistoryList = [];

    for (Map<String, dynamic> data in allData) {
      travelHistoryList.add(TravelHistory.fromJson(data));
    }


    for (TravelHistory travelHistory in travelHistoryList) {
      DriverProvider driverProvider = new DriverProvider();
      Driver driver = await driverProvider.getById(travelHistory.idDriver);
      travelHistory.nameDriver = driver.username;
    }


    return travelHistoryList;
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<TravelHistory> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();

    if (document.exists) {
      TravelHistory client = TravelHistory.fromJson(document.data());
      return client;
    }

    return null;
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

  Future<void> delete(String id) {
    return _ref.doc(id).delete();
  }

  ////////////////////////////////////////////////////////////////////////

  Future<ResponseApi>createDB(TravelHistory travelHistory) async {

    print('============holiiiiii');

    try {
      Uri url = Uri.https(_url, '$_api/create');
      String bodyParams = json.encode(travelHistory);
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


  Future<TravelHistory> getByIdDB(String id) async {
    DocumentSnapshot documentSnapshot = await _ref.doc(id).get();
    TravelHistory tra= TravelHistory.fromJson(documentSnapshot.data());
    print(tra);
    return tra;
  }

  Future<TravelHistory> getByIdFirebaseDB(String id)async{

    try{
      Uri url = Uri.https(_url, '$_api/findByIdFirebase/$id');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        //'Authorization': clientTok.session_token
      };
      final res = await http.get(url,headers: headers);
      if(res.statusCode==401){ //No Authorized

      }
      final data = json.decode(res.body);
      TravelHistory travelHistory =TravelHistory.fromJson(data);
      return travelHistory;
    }
    catch(e){
      print('Error : =>$e');
      return null;

    }
  }

  Future<ResponseApi> updateCalification(TravelHistory travelHistory) async {
    try {
      Uri url = Uri.https(_url, '$_api/updateCalificationClient');
      String bodyParams = json.encode(travelHistory);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        //'Authorization': clientDB.session_token
      };
      final res = await http.put(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        print('No se pudo actualizar');
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


  Future<Avg> averageCalification(String id)async{


    try{
      Uri url = Uri.https(_url, '$_api/averageCalification/$id');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        //'Authorization': clientTok.session_token
      };
      final res = await http.get(url,headers: headers);
      if(res.statusCode==401){ //No Authorized
        print('hubo un error en la actualizacion');
      }
      final data = json.decode(res.body);
      Avg avg =Avg.fromJson(data);
      print('Esta es una pruebaaaa = >${avg.avg}');
      return avg;
    }
    catch(e){
      print('Error : =>$e');
      return null;

    }
  }









}