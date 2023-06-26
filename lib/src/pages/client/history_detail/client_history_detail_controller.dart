import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/travel_history.dart';
import 'package:mi_flutter/src/models/driver.dart';


import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:mi_flutter/src/providers/travel_history_provider.dart';

class ClientHistoryDetailController{
  Function refresh;
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  TravelHistoryProvider _travelHistoryProvider;



  TravelHistory travelHistory;

  String idTravelHistory;
  DriverProvider _driverProvider;
  Driver driver;

  //AuthProvider _authProvider;



  Future init(BuildContext context,Function refresh )async{


    this.context =context;
    this.refresh=refresh;
    _travelHistoryProvider=new TravelHistoryProvider();
    idTravelHistory=ModalRoute.of(context).settings.arguments as String;
    //_authProvider=new AuthProvider();
    _driverProvider=new DriverProvider();
    driver= new Driver();
    getTravelHistoryInfo();


  }
  void getTravelHistoryInfo()async{
    travelHistory=await _travelHistoryProvider.getById(idTravelHistory);
    getDriverInfo(travelHistory.idDriver);

  }
  void getDriverInfo(String idDriver)async{
    driver=await _driverProvider.getById(idDriver);
    refresh();

  }






}
