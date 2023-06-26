import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:mi_flutter/src/models/travel_info.dart';
import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:mi_flutter/src/providers/geofire_provider.dart';
import 'package:mi_flutter/src/providers/travel_info_provider.dart';
import 'package:mi_flutter/src/utils/my_progress_dialog.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mi_flutter/src/models/driver.dart';

import '../../../api/environment.dart';
import '../../../providers/push_notification_provider.dart';
import '../../../providers/travel_history_provider.dart';
import '../../../widgets/bottom_sheet_client_info.dart';

class ClientTravelMapController {
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  Set<Polyline> polylines={};
  List<LatLng> points = [];




  CameraPosition initialPosition= CameraPosition(
      target: LatLng(-17.9786841,-67.1066987),
      zoom: 14.0
  );

  Map<MarkerId,Marker> markers = <MarkerId,Marker>{};



  BitmapDescriptor markerDriver;
  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;

  GeofireProvider _geofireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  PushNotificationProvider _pushNotificationProvider;
  TravelInfoProvider _travelInfoProvider;

  bool isConnect=false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot<Object>> _statusSuscription;
  StreamSubscription<DocumentSnapshot<Object>> _driverInfoSuscription;


  Driver driver;

  LatLng _driverLatLng;
  TravelInfo travelInfo;

  bool isRouteReady=false;

  String currentStatus='';
  Color colorStatus=Colors.grey[700];
  TravelHistoryProvider _travelHistoryProvider;

  bool isPickupTravel=false;
  bool isStartTravel=false;
  bool isFinishTravel=false;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _streamLocationController;

  StreamSubscription<DocumentSnapshot<Object>> _streamTravelController;











  Future init(BuildContext context, Function  refresh) async{
    this.context=context;
    this.refresh=refresh;

    _geofireProvider=new GeofireProvider();
    _authProvider=new AuthProvider();
    _driverProvider= new DriverProvider();
    _pushNotificationProvider=new PushNotificationProvider();
    _travelInfoProvider=new TravelInfoProvider();
    _travelHistoryProvider= new TravelHistoryProvider();

    _progressDialog=MyProgressDialog.createProggressDialog(context, 'Conectandose...');


    markerDriver=await createMarkerImageFromAssest('assets/img/icon_biker4.png');
    fromMarker=await createMarkerImageFromAssest('assets/img/icon_from2.png');
    toMarker=await createMarkerImageFromAssest('assets/img/icon_to2.png');

    checkGPS();




  }



  void getDriverLocation(String idDriver){
    //DocumentSnapshot<Map<String,dynamic>> document;
    Stream<DocumentSnapshot<Map<String,dynamic>>> stream = _geofireProvider.getLocationByidStream(idDriver);
    _streamLocationController =stream.listen((document) {
      GeoPoint geoPoint=document.data()['position']['geopoint'];
      print(geoPoint.latitude);
      print(geoPoint.latitude);
      print("-----4545----");
      _driverLatLng= new LatLng(geoPoint.latitude, geoPoint.longitude);


      if(!isPickupTravel){
        isPickupTravel=true;
        LatLng from = new LatLng(_driverLatLng.latitude,_driverLatLng.longitude);
        LatLng to = new LatLng(travelInfo.fromLat,travelInfo.fromLng);
        addSimpleMarker('from', to.latitude, to.latitude, 'Recoger Aqui', '', fromMarker);
        setPolylines(from, to);


      }



      addSimpleMarker('driver',
          _driverLatLng.latitude,
          _driverLatLng.longitude,
          'Tu conductor',
          '',
          markerDriver
      );
      _getTravelDisplay();
      refresh();

      if(!isRouteReady){
        isRouteReady=true;
        checkTravelStatus();
      }

    });


  }


  void pickupTravel(){
    if(!isPickupTravel){
      isPickupTravel=true;
      print("aca vamos bien");

        LatLng from = new LatLng(_driverLatLng.latitude,_driverLatLng.longitude);
        LatLng to = new LatLng(travelInfo.toLat,travelInfo.toLng);
        //addSimpleMarker('from', to.latitude, to.latitude, 'Recoger Aqui', '', fromMarker);
        setPolylines(from, to);

    }

  }

  void checkTravelStatus()async{
    Stream<DocumentSnapshot> stream=_travelInfoProvider.getByIdStream(_authProvider.getUser().uid);
    _streamTravelController = stream.listen((DocumentSnapshot document) {
      travelInfo=TravelInfo.fromJson(document.data());

      if(travelInfo.status=='accepted'){
        currentStatus='Viaje Aceptado';
        colorStatus=Colors.lightGreen;
        pickupTravel();

      } else if(travelInfo.status=='started') {
        print ('================================llego a viaje iniciado');
        currentStatus = 'Viaje Iniciado';
        colorStatus=Colors.amber;
        startTravel();
      }else if(travelInfo.status=='finished') {
        currentStatus = 'Viaje Finalizado';
        colorStatus=Colors.deepOrangeAccent;
        finishTravel();

      }
      refresh();

    });
  }


  void openBottomSheet() {
    if (driver == null) return;

    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetClientInfo(
          imageUrl: driver?.image,
          username: driver?.username,
          email: driver?.email,
          plate: driver?.plate,
        )
    );
  }


  void finishTravel(){
    if(!isFinishTravel){
      isFinishTravel=true;
      print('=============== weeeyyy la id del travel =====================================================================================');
      print(travelInfo.idTravelHistory);
      Navigator.pushNamedAndRemoveUntil(context, 'client/travel/calification', (route) => false,arguments: travelInfo.idTravelHistory);
    }

  }



  void startTravel(){
    if(!isStartTravel){
      isStartTravel=true;
      polylines={};
      points= [];
      //markers.remove(markers['from']);
      markers.removeWhere((key, marker) => marker.markerId.value=='from'); //eliminar marcador
      addSimpleMarker(
          'to',
          travelInfo.toLat,
          travelInfo.toLng,
          'Destino',
          '',
          toMarker
      );
      LatLng from = new LatLng(_driverLatLng.latitude,_driverLatLng.longitude);
      LatLng to = new LatLng(travelInfo.toLat,travelInfo.toLng);

      //addSimpleMarker('from', to.latitude, to.latitude, 'Recoger Aqui', '', toMarker);
      setPolylines(from, to);



      refresh();
    }


  }



  void _getTravelInfo()async{
    travelInfo=await _travelInfoProvider.getById(_authProvider.getUser().uid);
    animateCamaraToPosition(travelInfo.fromLat, travelInfo.fromLng);
    getDriverInfo(travelInfo.idDriver);
    getDriverLocation(travelInfo.idDriver);

  }

  void _getTravelDisplay(){
    if(isStartTravel==true){


    print(_driverLatLng.latitude);
    print(_driverLatLng.longitude);
    animateCamaraToPosition(_driverLatLng.latitude, _driverLatLng.longitude);}
  }

  void getDriverInfo(String id) async{

    driver=await _driverProvider.getById(id);
    refresh();

  }




  Future<void> setPolylines(LatLng from, LatLng to) async {
    PointLatLng pointFromLatLng = PointLatLng(from.latitude, from.longitude);
    PointLatLng pointToLatLng = PointLatLng(to.latitude, to.longitude);
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        Environment.API_KEY_MAPS,
        pointFromLatLng,
        pointToLatLng);
    for (PointLatLng point in result.points) {
      points.add(LatLng(point.latitude, point.longitude));
    }
    Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: Colors.amber,
        points: points,
        width: 6
    );
    polylines.add(polyline);
    addSimpleMarker('from', to.latitude, to.longitude, 'Recoger aqui', '', fromMarker);
    //addMarker('from', fromLatLng.latitude, fromLatLng.latitude, 'Recoger aqui', '', fromMarker);
    refresh();
  }


  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(
        '[{"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},{"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#64779e"}]},{"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},{"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#334e87"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#023e58"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#283d6a"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#6f9ba5"}]},{"featureType":"poi","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#023e58"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#3C7680"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#304a7d"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},{"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2c6675"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#255763"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#b0d5ce"}]},{"featureType":"road.highway","elementType":"labels.text.stroke","stylers":[{"color":"#023e58"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},{"featureType":"transit","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"transit.line","elementType":"geometry.fill","stylers":[{"color":"#283d6a"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#3a4762"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1626"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4e6d70"}]}]');
    _mapController.complete(controller);
    _getTravelInfo();

  }


  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS activado');

    } else {
      print('GPS desactivado');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {

        print('ACTIVO EL GPS');
      }
    }
  }










  Future animateCamaraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(latitude, longitude),
            zoom: 17,
          )
      ));
    }
  }


  Future<BitmapDescriptor> createMarkerImageFromAssest(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescritor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescritor;
  }




  void addSimpleMarker(String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content),

    );

    markers[id] = marker;
  }


  void dispose() {
    //metodo que elimina los listen para que la app no sea tan pesada

    _statusSuscription?.cancel();
    _driverInfoSuscription?.cancel();
    _streamLocationController?.cancel();
    _streamTravelController?.cancel();
  }
}

