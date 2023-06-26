import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/travel_history.dart';
import 'package:mi_flutter/src/providers/travel_history_provider.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;


class DriverTravelCalificationController {

  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey();
  Function refresh;

  String idTravelHistory;

  TravelHistoryProvider _travelHistoryProvider;
  TravelHistory travelHistory;

  double calification;

  Future init (BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;

    idTravelHistory = ModalRoute.of(context).settings.arguments as String;

    _travelHistoryProvider = new TravelHistoryProvider();

    print('ID DEL TRAVBEL HISTORY: $idTravelHistory');

    getTravelHistory();
  }

  void calificate () async {
    if (calification == null || calification == 0) {
      utils.Snackbar.showSnackbar(
          context, key, 'Por favor califica a tu conductor');
      return;
    }
    else if ( calification < 1) {
      utils.Snackbar.showSnackbar(
          context, key, 'La calificacion minima debe ser 1');
      return;
    } else {
      Map<String, dynamic> data = {

        'calificationClient': calification
      };
      calificateDB(calification);

      await _travelHistoryProvider.update(data, idTravelHistory);
      Navigator.pushNamedAndRemoveUntil(
          context, 'driver/map', (route) => false);
    }
  }

  void calificateDB(double calificationDB)async{
    TravelHistory travelDB= new TravelHistory(
        calificationClient: calificationDB
    );
    await _travelHistoryProvider.updateCalification(travelDB);
  }

  void getTravelHistory() async {
    travelHistory = await _travelHistoryProvider.getById(idTravelHistory);
    refresh();
  }




}