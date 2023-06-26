
import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/travel_history.dart';
import 'package:mi_flutter/src/providers/travel_history_provider.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;


class ClientTravelCalificationController {
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey();
  Function refresh;

  String idTravelHistory;

  TravelHistoryProvider _travelHistoryProvider;
  TravelHistory travelHistory;
  TravelHistory travelHistoryDB;

  double calification;


  Future init(BuildContext context, Function refresh){
    this.context=context;
    this.refresh=refresh;


    idTravelHistory= ModalRoute.of(context).settings.arguments as String;

    _travelHistoryProvider= new TravelHistoryProvider();
    travelHistory=new TravelHistory();
    print('ID del  TRAVEL HISTORY: $idTravelHistory');

    getTravelHistory();



  }


  void calificate()async{
    if(calification==null|| calification == 0){
      utils.Snackbar.showSnackbar(context, key, 'Por favor califica a tu conductor');
      return;
    }
    if(calification<1){
      utils.Snackbar.showSnackbar(context, key, 'La calificacion mínima es 1');
      return;
    }
    Map<String,dynamic> data ={
      'calificationDriver':calification
    };
    calificateDB(calification);
    await _travelHistoryProvider.update(data,idTravelHistory);


    Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
  }

  void calificateDB(double calificationDB)async{
    TravelHistory travelDB= new TravelHistory(
      calificationDriver: calificationDB
    );
    await _travelHistoryProvider.updateCalification(travelDB);
  }


  void getTravelHistory()async{
    travelHistory=await _travelHistoryProvider.getById(idTravelHistory);
    travelHistoryDB=await _travelHistoryProvider.getByIdFirebaseDB(idTravelHistory);

    refresh();
    print(travelHistory.from);
    print(travelHistory.to);

  }


}