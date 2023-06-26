import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/travel_history.dart';
import 'package:mi_flutter/src/models/travel_info.dart';
import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/client_provider.dart';
import 'package:mi_flutter/src/providers/geofire_provider.dart';
import 'package:mi_flutter/src/providers/travel_history_provider.dart';
import 'package:mi_flutter/src/providers/travel_info_provider.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;

import '../../../models/client.dart';

class DriverTravelRequestController {
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey();
  Function refresh;
  SharedPref _sharedPref;


  String from;
  String to;
  String idClient;
  String idClientDB;
  String idDriverDB;
  Client client;

  ClientProvider _clientProvider;
  TravelInfoProvider _travelInfoProvider;
  AuthProvider _authProvider;
  GeofireProvider _geofireProvider;
  
  Timer _timer;
  int seconds=30;


  TravelInfo travelInfo;
  StreamSubscription<DocumentSnapshot<Object>> _streamTravelController;
  StreamSubscription<DocumentSnapshot> _streamStatusSubscription;



  Future init(BuildContext context, Function refresh){
    this.context=context;
    this.refresh=refresh;
    _sharedPref=new SharedPref();
    _sharedPref.save('isNotification', 'false');
    _clientProvider= new ClientProvider();
    _travelInfoProvider= new TravelInfoProvider();
    _authProvider= new AuthProvider();
    _geofireProvider=new GeofireProvider();


    Map<String,dynamic> arguments= ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
    from=arguments['origin'];
    to=arguments['destination'];
    idClient=arguments['idClient'];
    idClientDB=arguments['idClientDB'];







    getClientInfo();


    refresh();
    startTimer();
  }

  void dispose(){
    _timer.cancel();
    _streamTravelController?.cancel();

    _streamStatusSubscription.cancel();

  }
  
  void startTimer(){
    _timer=Timer.periodic(Duration(seconds: 1), (timer) {
      seconds= seconds-1;
      refresh();
      _checkMyResponse();
      if(seconds==0){
        cancelTravel();
      }
    });

  }





  void acceptTravel(){
    Map<String,dynamic> data ={
      'idDriver':_authProvider.getUser().uid,
      'status':'accepted'

    };
    _timer?.cancel();
    _travelInfoProvider.update(data, idClient);
    _geofireProvider.delete(_authProvider.getUser().uid);
    /*Map<String,dynamic> idsClient={

      'idClient':idClient,
      'idClientDB':idClientDB

    };*/
    Navigator.pushNamedAndRemoveUntil(context, 'driver/travel/map', (route) => false,arguments: idClient);
    //Navigator.pushNamedAndRemoveUntil(context, 'driver/travel/map', (route) => false,arguments: idsClient);
    //Navigator.pushReplacementNamed (context, 'driver/travel/map',arguments: idClient);

  }
  void cancelTravel(){
    Map<String,dynamic> data ={

      'status':'no_accepted'

    };
    _timer?.cancel();
    _travelInfoProvider.update(data, idClient);
    Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);

  }






  void _checkMyResponse() async{


    Stream<DocumentSnapshot> stream= _travelInfoProvider.getByIdStream(client.id);
    _streamStatusSubscription= stream.listen((DocumentSnapshot document) {
      TravelInfo travelInfo=TravelInfo.fromJson(document.data());

       if(travelInfo.status=='no_accepted'){
        //utils.Snackbar.showSnackbar(context, key, 'El cliente cancelo el viaje');
        print('El cliente cancelo el viaje');
        utils.Snackbar.showSnackbar(context, key, 'El cliente cancelo el viaje');
        _travelInfoProvider.delete(client.id);
          Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
          utils.Snackbar.showSnackbar(context, key, 'El cliente cancelo el viaje');
          _streamStatusSubscription.cancel();







      }
    });
  }


  void getClientInfo()async{


   client =await _clientProvider.getById(idClient);
   _checkMyResponse();

  }



}