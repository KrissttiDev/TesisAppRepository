import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_flutter/src/api/environment.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';

import '../models/response_api.dart';
class ProductsProvider{
  String _url = Environment.API_DELIVERY;
  String _api = '/api/products';
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


  Future<List<Product>> getbyCategory(String idCAtegory) async{

    try {
      Uri url = Uri.https(_url, '$_api/findByCategory/$idCAtegory');
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
      Product product= Product.fromJsonList(data);
      return product.toList;

    }
    catch(e){
      print('Error : $e');
      return [];

    }
  }

  Future<List<Product>> getByCategoryAndProductName(String idCAtegory, String productName) async{

    try {
      Uri url = Uri.https(_url, '$_api/findByCategoryAndProductName/$idCAtegory/$productName');
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
      Product product= Product.fromJsonList(data);
      return product.toList;

    }
    catch(e){
      print('Error : $e');
      return [];

    }
  }




  Future<Stream> create(Product product,List<File> images)async {
    try{
      Uri url = Uri.https(_url, '$_api/create');
      final request=http.MultipartRequest('POST',url);
      request.headers['Authorization']= clientDB.session_token;
      for(int i=0; i<images.length;i++){
        request.files.add(http.MultipartFile(
            'image',
            http.ByteStream(images[i].openRead().cast()),
            await images[i].length(),
            filename: basename(images[i].path)
        ));
      }

      request.fields['product']=json.encode(product);
      final response =await request.send(); //ENVIARA LA PETICION
      return response.stream.transform(utf8.decoder);

    }
    catch(e){
      print('Error: $e');
      return null;

    }

  }











}