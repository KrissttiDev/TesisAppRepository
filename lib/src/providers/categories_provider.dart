import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mi_flutter/src/api/environment.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:mi_flutter/src/utils/share_pref.dart';

import '../models/response_api.dart';
class CategoriesProvider{
  String _url = Environment.API_DELIVERY;
  String _api = '/api/categories';
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



  Future<List<Category>> getAll() async{

      try {
        Uri url = Uri.https(_url, '$_api/getAll');
        Map<String, String> headers = {
          'Content-type': 'application/json',
          'Authorization': clientDB.session_token
        };

        final res = await http.get(url, headers: headers);
        if(res.statusCode==401){
          Fluttertoast.showToast(msg: 'Session Expirada');
          new SharedPref().logoutBD(context,clientDB);
        }
        final data = json.decode(res.body); // devolviento las categorias
        Category category= Category.fromJsonList(data);
        return category.toList;

    }
    catch(e){
      print('Error : $e');
      return [];

    }



  }



  Future<ResponseApi>createDB(Category category) async {

    print('============holiiiiii');

    try {
      Uri url = Uri.https(_url, '$_api/create');
      String bodyParams = json.encode(category);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': clientDB.session_token
      };

      final res = await http.post(url, headers: headers, body: bodyParams);
      if(res.statusCode==401){
        Fluttertoast.showToast(msg: 'Session Expirada');
        new SharedPref().logoutBD(context,clientDB);
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