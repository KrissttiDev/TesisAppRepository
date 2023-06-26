import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/order.dart';

import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/providers/clientD_provider.dart';

import 'package:mi_flutter/src/providers/client_provider.dart';
import 'package:mi_flutter/src/providers/orders_provider.dart';
import 'package:mi_flutter/src/providers/push_notification_provider.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as MySnackBar;


class RestaurantOrdersDetailController {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Product product;
  Order order;

  SharedPref _sharedPrefDB = new SharedPref();


  int counter=1;

  double total=0;
  Client clientDB =new Client();

  List<Client> clients=[];
  List<Client> asd=[];
  ClientDProvider _clientDProvider= new ClientDProvider();
  ClientProvider _clientProvider=new ClientProvider();
  OrdersProvider _ordersProvider= new OrdersProvider();
  PushNotificationProvider pushNotificationProvider=new PushNotificationProvider();

  String idDelivery;



  Future init(BuildContext context,Function refresh, Order order)async{
    this.context= context;
    this.refresh=refresh;
    this.order=order;


    clientDB =Client.fromJson(await _sharedPrefDB.readDB('userDB')??{});


    _clientDProvider.init(context,clientDB: clientDB);
    _ordersProvider.init(context, clientDB);
    getTotal();
    getUser();
    refresh();



  }

  void sendNotification(String tokenD)async{
    Map<String,dynamic> data={
      'click_action':'FLUTTER_NOTIFICATION_CLICK'
    };
    pushNotificationProvider.sendMessageDB(
        tokenD, 
        data, 
        'PEDIDO ASIGNADO', 
        'Te han asignado un pedido'
    );
  }


  void updateOrder()async{
    if(idDelivery!=null){
      order.idDelivery=idDelivery;
      ResponseApi responseApi= await _ordersProvider.updateToDispachedDB(order);
      
      Client deliveryUser=await _clientProvider.getByIdDB(order.id, clientDB);
      sendNotification(deliveryUser.token);
      
      
      Fluttertoast.showToast(msg: responseApi.message, toastLength: Toast.LENGTH_LONG);
      Navigator.pop(context, true);

    }else{
      Fluttertoast.showToast(msg: 'Selecciona un Repartidor');
    }


  }

  void getUser() async{
    clients= await _clientDProvider.getDeliveryMen();

    refresh();

  }



  void getTotal() {
    total = 0;
    order.products.forEach((product) {
      total=total+(product.price*product.quantity);
    });

    refresh();
  }



  void goToAddress(){
    Navigator.pushNamed(context, 'client/address/list');
  }




















}