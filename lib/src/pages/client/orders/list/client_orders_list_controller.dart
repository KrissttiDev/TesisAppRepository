import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/pages/client/orders/detail/client_orders_detail_page.dart';
import 'package:mi_flutter/src/pages/delivery/orders/detail/delivery_orders_detail_page.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/models/order.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/orders/detail/restaurant_orders_detail_page.dart';
import 'package:mi_flutter/src/providers/orders_provider.dart';


import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ClientOrdersListController {
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();



  Client client;
  Client clientDB = new Client();



  SharedPref _sharedPrefDB= new SharedPref();
  String tok;
  String user;


  List<String> status = ['PAGADO','DESPACHADO', 'EN CAMINO', 'ENTREGADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();
  List<Order> p;


  bool isUpdated;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;


    //_sharedPrefDB=new SharedPref();


    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));

    _ordersProvider.init(context,clientDB);
    refresh();
    print(clientDB.username);
  }

  Future<List<Order>> getOrders(String status)  async {

    return await _ordersProvider.getByClientAndStatus(clientDB.id, status);



  }

  void openBottomSheet(Order order) async {
    isUpdated = await showMaterialModalBottomSheet(
        context: context,
        builder: (context) => ClientOrdersDetailPage(order: order)

    );

    if (isUpdated) {
      refresh();
    }


  }

  void logout() {
    _sharedPrefDB.logoutBD(context, clientDB);
  }



  void openDrawer() {
    key.currentState.openDrawer();
  }

  void goToEditPage(){
    print(clientDB.session_token);
    Navigator.pushNamed(context, 'client/edit');
  }

  void goToRoles() {
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }

}