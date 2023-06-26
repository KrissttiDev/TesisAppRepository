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
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as MySnackBar;


class DeliveryOrdersDetailController {

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
  OrdersProvider _ordersProvider= new OrdersProvider();

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


  void updateOrder() async {
    if (order.status == 'DESPACHADO') {
      ResponseApi responseApi = await _ordersProvider.updateToTheWayDB(order);
      Fluttertoast.showToast(msg: responseApi.message, toastLength: Toast.LENGTH_LONG);
      if (responseApi.success) {
        Navigator.pushNamed(context, 'delivery/orders/map', arguments: order?.toJson());
      }
    }
    else {
      Navigator.pushNamed(context, 'delivery/orders/map', arguments: order?.toJson());
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