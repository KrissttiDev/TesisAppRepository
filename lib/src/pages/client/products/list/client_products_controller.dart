import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/category.dart';


import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/pages/client/products/detail/client_products_details_page.dart';
import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/categories_provider.dart';
import 'package:mi_flutter/src/providers/client_provider.dart';

import 'package:mi_flutter/src/providers/geofire_provider.dart';
import 'package:mi_flutter/src/providers/products_provider.dart';
import 'package:mi_flutter/src/providers/push_notification_provider.dart';

import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';




class ClientProductsListController{
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();



  AuthProvider _authProvider;

  ClientProvider _clientProvider;


  SharedPref _sharedPref;
  SharedPref _sharedPrefDB;
  ProductsProvider _productsProvider;


  Client client;
  Client clientDB;
   CategoriesProvider _categoriesProvider= new CategoriesProvider();
   PushNotificationProvider pushNotificationProvider=new PushNotificationProvider();
  List<Category> categories=[];

  Timer searchOnStoppedTyping;
  String productName='';
  List<String> tokens=[];



  Future init(BuildContext context, Function  refresh) async{
    this.context=context;
    this.refresh=refresh;

    _authProvider=new AuthProvider();
    _clientProvider=new ClientProvider();
    _sharedPref=new SharedPref();
    _sharedPrefDB=new SharedPref();
    _productsProvider= new ProductsProvider();
    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));
    _categoriesProvider.init(context, clientDB);
    _productsProvider.init(context, clientDB);


    tokens=await _clientProvider.getAdminsNotificationTokens();
    sendNotification();

    refresh();
    getCategories();


  }

  void sendNotification()async{
    List<String> registration_ids=[];

    tokens.forEach((token) {
      if(token!=null){
        registration_ids.add(token);
      }
    });

    Map<String,dynamic> data={
      'click_action':'FLUTTER_NOTIFICATION_CLICK'
    };
    pushNotificationProvider.sendMessageMultipleDB(
        tokens,
        data,
        'COMPRA EXITOSA',
        'Un cliente ha realizado un pedido'
    );
  }



  Future<List<Product>> getProducts(String idCategory,String productName) async{
    if(productName.isEmpty){
      return await _productsProvider.getbyCategory(idCategory);

    }else{
      return await _productsProvider.getByCategoryAndProductName(idCategory,productName);
    }

  }

  void getCategories() async{
    categories = await _categoriesProvider.getAll();
    refresh();


  }


  void onChangedText(String text){
    Duration duration=Duration(milliseconds: 800);
    if(searchOnStoppedTyping!=null){
      searchOnStoppedTyping.cancel();
      refresh();
    }
    searchOnStoppedTyping= new Timer(duration, (){
      productName=text;
      refresh();
      print('TEXTO COMPLETO: ${productName}');

    });
  }

  void openBottomSheet(Product product){
    /*showModalBottomSheet(

        context: context,
        builder: (context)=>ClientProductsDetailPage(product: product),


    );*/
    showBarModalBottomSheet(
        expand: true,
        context: context,
        builder: (context)=>ClientProductsDetailPage(product: product),
    );
  }


  void openDrawer() {

    key.currentState.openDrawer();

  }



  void goToEditPage(){
    print(clientDB.session_token);
    Navigator.pushNamed(context, 'client/edit');
  }
  void goToRolPages(){
    print(clientDB.session_token);
    Navigator.pushNamed(context, 'roles');
  }



  void goToCreatePage(){
    Navigator.pushNamed(context, 'client/orders/create');
  }

  void goToOrdersList(){
    Navigator.pushNamed(context, 'client/orders/list');
  }

  void singOut() async{
    await _clientProvider.logoutDB(clientDB.id);
    await _authProvider.singOut();
    await _sharedPrefDB.removeDB('userDB');

    //await _clientProvider.logoutDB(clientDB.id);


    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);

  }

}


