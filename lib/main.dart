import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mi_flutter/src/pages/client/address/create/client_address_create_page.dart';
import 'package:mi_flutter/src/pages/client/address/list/client_address_list_page.dart';
import 'package:mi_flutter/src/pages/client/address/map/client_address_map_page.dart';
import 'package:mi_flutter/src/pages/client/edit/client_edit_page.dart';
import 'package:mi_flutter/src/pages/client/history/client_history_page.dart';
import 'package:mi_flutter/src/pages/client/history_detail/client_history_detail_page.dart';
import 'package:mi_flutter/src/pages/client/map/client_map_page.dart';

import 'package:mi_flutter/src/pages/client/orders/create/client_orders_create_page.dart';
import 'package:mi_flutter/src/pages/client/orders/list/client_orders_list_page.dart';
import 'package:mi_flutter/src/pages/client/orders/map/client_orders_map_page.dart';
import 'package:mi_flutter/src/pages/client/payments/create/client_payments_create_controller.dart';
import 'package:mi_flutter/src/pages/client/payments/create/client_payments_create_page.dart';
import 'package:mi_flutter/src/pages/client/register/client_register_page.dart';
import 'package:mi_flutter/src/pages/client/travel_calification/client_travel_calification_page.dart';
import 'package:mi_flutter/src/pages/client/travel_info/client_travel_info_page.dart';
import 'package:mi_flutter/src/pages/client/travel_map/client_travel%20_map_page.dart';
import 'package:mi_flutter/src/pages/client/travel_request/client_travel_request_page.dart';
import 'package:mi_flutter/src/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:mi_flutter/src/pages/delivery/orders/map/delivery_orders_map_page.dart';
import 'package:mi_flutter/src/pages/driver/edit/driver_edit_page.dart';
import 'package:mi_flutter/src/pages/driver/map/driver_map_page.dart';
import 'package:mi_flutter/src/pages/driver/register/driver_register_page.dart';
import 'package:mi_flutter/src/pages/driver/travel_calification/driver_travel_calification_page.dart';
import 'package:mi_flutter/src/pages/driver/travel_map/driver_travel%20_map_page.dart';
import 'package:mi_flutter/src/pages/driver/travel_request/driver_travel_request_page.dart';
import 'package:mi_flutter/src/pages/home/home_page.dart';
import 'package:mi_flutter/src/pages/login/login_page.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/create/restaurant_categories_create_page.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/orders/detail/restaurant_orders_detail_page.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/orders/list/restaurant_orders_list_page.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/products/create/restaurant_products_create_page.dart';
import 'package:mi_flutter/src/pages/roles/roles_page.dart';
import 'package:mi_flutter/src/providers/push_notification_provider.dart';
import 'package:mi_flutter/src/utils/colors.dart'as utils;


import 'src/pages/client/products/list/client_products_page.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);



  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  GlobalKey<NavigatorState> navigatorKey= new GlobalKey<NavigatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PushNotificationProvider pushNotificationProvider= new PushNotificationProvider();
    pushNotificationProvider.initPushNotification();
    pushNotificationProvider.onMessageListenerDB();
    pushNotificationProvider.message.listen((data) {
      print('------------------NOTIFICACION-------------------------');

      if(data.isEmpty){
        print('Datos vacios- notificacion cliente- mapa del viaje del cliente');


      }else{
      navigatorKey.currentState.pushNamed('driver/travel/request',arguments: data);}



    });
  }



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uber Clone',
      navigatorKey: navigatorKey,
      initialRoute: 'home',
      //initialRoute: 'restaurant/products/list',
      theme: ThemeData(
        fontFamily: 'NimbusSans',
        appBarTheme: AppBarTheme(
          color: utils.Colors.uberCloneColor,
          elevation: 0
        ),

        primaryColor: utils.Colors.uberCloneColor
      ),
      routes: {
        'home':(BuildContext context)=> HomePage(),
        'login':(BuildContext context)=> LoginPage(),
        'client/register':(BuildContext context)=> ClientRegisterPage(),
        'client/map':(BuildContext context)=>ClientMapPage(),
        'driver/register':(BuildContext context)=> DriverRegisterPage(),
        'driver/map':(BuildContext context)=> DriverMapPage(),
        'client/travel/info':(BuildContext context)=>ClientTravelInfoPage(),
        'client/travel/request':(BuildContext context)=>ClientTravelRequestPage(),
        'driver/travel/request':(BuildContext context)=>DriverTravelRequestPage(),
        'driver/travel/map':(BuildContext context)=>DriverTravelMapPage(),
        'client/travel/map':(BuildContext context)=>ClientTravelMapPage(),
        'driver/travel/calification':(BuildContext context)=>DriverTravelCalificationPage(),
        'client/travel/calification':(BuildContext context)=>ClientTravelCalificationPage(),
        'client/edit':(BuildContext context)=>ClientEditPage(),
        'driver/edit':(BuildContext context)=>DriverEditPage(),
        'client/history':(BuildContext context)=>ClientHistoryPage(),
        'client/history/detail':(BuildContext context)=>ClientHistoryDetailPage(),


        'roles':(BuildContext context)=>RolesPage(),
        'client/products/list':(BuildContext context)=>ClientProductsListPage(),
        'client/orders/create':(BuildContext context)=>ClientOrdersCreatePage(),
        'client/address/list':(BuildContext context)=>ClientAddressListPage(),
        'client/address/create':(BuildContext context)=>ClientAddressCreatePage(),
        'client/address/map':(BuildContext context)=>ClientAddressMapPage(),
        'client/orders/list':(BuildContext context)=>ClientOrdersListPage(),
        'client/payments/create':(BuildContext context)=>ClientPaymentsCreatePage(),


        'restaurant/orders/list':(BuildContext context)=>RestaurantOrdersListPage(),
        'restaurant/categories/create':(BuildContext context)=>RestaurantCategoriesCreatePage(),
        'restaurant/orders/detail':(BuildContext context)=>RestaurantOrdersDetailPage(),
        'restaurant/products/create':(BuildContext context)=>RestaurantProductsCreatePage(),

        'delivery/orders/list':(BuildContext context)=>DeliveryOrdersListPage(),
        'delivery/orders/map':(BuildContext context)=>DeliveryOrdersMapPage(),
        'client/orders/map':(BuildContext context)=>ClientOrdersMapPage(),






        //-----------------------------------











      },

    );
  }
}

