import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/driver.dart';

import 'package:mi_flutter/src/models/travel_info.dart';
import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:mi_flutter/src/providers/geofire_provider.dart';
import 'package:mi_flutter/src/providers/push_notification_provider.dart';
import 'package:mi_flutter/src/providers/travel_info_provider.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;

class ClientTravelRequestController{


  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  String from;
  String to;
  LatLng fromLatLng;
  LatLng toLatLng;

  TravelInfoProvider _travelInfoProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  GeofireProvider _geofireProvider;
  PushNotificationProvider _pushNotificationProvider;
  SharedPref _sharedPrefDB;
  Client clientDB;

  List<String> nearbyDrivers= [];
  StreamSubscription <List<DocumentSnapshot>> _streamSubscription;
  StreamSubscription<DocumentSnapshot> _streamStatusSubscription;

  Future init(BuildContext context, Function refresh)async{
    this.context=context;
    this.refresh=refresh;
    _travelInfoProvider=new TravelInfoProvider();
    _authProvider= new AuthProvider();
    _driverProvider= new DriverProvider();
    _geofireProvider =new GeofireProvider();
    _pushNotificationProvider=new PushNotificationProvider();
    _sharedPrefDB=new SharedPref();
    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));


    Map<String, dynamic> arguments= ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
    from=arguments['from'];
    to=arguments['to'];
    fromLatLng=arguments['fromLatLng'];
    toLatLng=arguments['toLatLng'];

    _createTravelInfo();
    _getNearbyDrivers();

  }

  void dispose() {
    _streamSubscription?.cancel();
    _streamStatusSubscription.cancel();
  }


  void _getNearbyDrivers(){
    Stream<List<DocumentSnapshot>> stream =_geofireProvider.getNearbyDrivers(
        fromLatLng.latitude,
        fromLatLng.longitude,
        7);
   _streamSubscription= stream.listen((List<DocumentSnapshot> documentList) {
     for(DocumentSnapshot d in documentList){
       print('CONDUCTOR ENCONTRADO ${d.id}');
       nearbyDrivers.add(d.id);
     }
     getDriverInfo(nearbyDrivers[0]);
     _streamSubscription.cancel();
   });
  }


  void cancelTravel(){
    Map<String,dynamic> data ={

      'status':'no_accepted'

    };


    _travelInfoProvider.update(data, _authProvider.getUser().uid);
    dispose();
    Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);

  }


  void _checkDriverResponse(){
    Stream<DocumentSnapshot> stream= _travelInfoProvider.getByIdStream(_authProvider.getUser().uid);
    _streamStatusSubscription= stream.listen((DocumentSnapshot document) {
      TravelInfo travelInfo=TravelInfo.fromJson(document.data());

      if(travelInfo!=null&&travelInfo.status=='accepted'){
        Navigator.pushNamedAndRemoveUntil(context, 'client/travel/map', (route) => false);
        //Navigator.pushReplacementNamed(context, 'client/travel/map');


      }else if(travelInfo.status=='no_accepted'){
        utils.Snackbar.showSnackbar(context, key, 'El conductor no acepto tu solicitud');
        Future.delayed(Duration(milliseconds: 4000),(){
          Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);

        });




      }
    });
  }



  void _createTravelInfo() async{
    TravelInfo travelInfo=new TravelInfo(
      id:_authProvider.getUser().uid,
      idClientDB:clientDB.id,
      from: from,
      to: to,
      fromLat: fromLatLng.latitude,
      fromLng: fromLatLng.longitude,
      toLat: toLatLng.latitude,
      toLng: toLatLng.longitude,
      status:'created'
    );
    await _travelInfoProvider.create(travelInfo);
    _checkDriverResponse();
  }


  Future<void> getDriverInfo(String idDriver) async{
    Driver driver = await _driverProvider.getById(idDriver);
   _sendNotification(driver.token);
  }


  void _sendNotification(String token){
    Map<String,dynamic> data={
      'click_action':'FLUTTER_NOTIFICATION_CLICK',
      'idClient':_authProvider.getUser().uid,
      'idClientDB':clientDB.id,
      'origin':from,
      'destination':to
    };
    _pushNotificationProvider.sendMessage(token, data,'Solicitud de Servicio','Un cliente esta solicitando un viaje');

  }

}