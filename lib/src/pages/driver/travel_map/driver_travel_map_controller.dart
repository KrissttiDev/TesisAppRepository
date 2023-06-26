import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:mi_flutter/src/models/travel_history.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/prices.dart';
import 'package:mi_flutter/src/models/travel_info.dart';
import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/client_provider.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:mi_flutter/src/providers/geofire_provider.dart';
import 'package:mi_flutter/src/providers/prices_provider.dart';
import 'package:mi_flutter/src/providers/travel_history_provider.dart';
import 'package:mi_flutter/src/providers/travel_info_provider.dart';
import 'package:mi_flutter/src/utils/my_progress_dialog.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:mi_flutter/src/widgets/bottom_sheet_client_info.dart';
import 'package:mi_flutter/src/widgets/bottom_sheet_driver_info.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mi_flutter/src/models/driver.dart';

import '../../../api/environment.dart';
import '../../../providers/push_notification_provider.dart';

class DriverTravelMapController {


  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  Set<Polyline> polylines={};
  List<LatLng> points = [];

  bool isNotificate=false;




  CameraPosition initialPosition= CameraPosition(
      target: LatLng(-17.9786841,-67.1066987),
      zoom: 14.0
  );

  Map<MarkerId,Marker> markers = <MarkerId,Marker>{};
  Position _position;
  StreamSubscription<Position> _positionStream;

  BitmapDescriptor markerDriver;
  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;

  GeofireProvider _geofireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  PushNotificationProvider _pushNotificationProvider;
  TravelInfoProvider _travelInfoProvider;
  PricesProvider _pricesProvider;
  ClientProvider _clientProvider;
  Client _client;
  Client _clientp;
  String _idClientDB;

  TravelHistoryProvider _travelHistoryProvider;

  bool isConnect=false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot<Object>> _statusSuscription;
  StreamSubscription<DocumentSnapshot<Object>> _driverInfoSuscription;


  Driver driver;
  Driver driverdb;

  String _idTravel;
  TravelInfo travelInfo;

  SharedPref _sharedPrefdb;

  String currentStatus='Iniciar Viaje';
  Color colorStatus=Colors.amber;

  double _distaceBetween;

  Timer _timer;
  int seconds=0;
  int seg;
  double min=0;
  double mt=0;
  double km=0;





  Future init(BuildContext context, Function  refresh) async{
    this.context=context;
    this.refresh=refresh;
    _idTravel=ModalRoute.of(context).settings.arguments as String;
    /*Map<String, dynamic> idsClient= ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
    _idTravel=idsClient['idClient'];
    _idClientDB=idsClient['idClientDB'];*/

    _geofireProvider=new GeofireProvider();
    _authProvider=new AuthProvider();
    _driverProvider= new DriverProvider();
    _pushNotificationProvider=new PushNotificationProvider();
    _travelInfoProvider=new TravelInfoProvider();
    _pricesProvider = new PricesProvider();
    _clientProvider=new ClientProvider();
    _travelHistoryProvider= new TravelHistoryProvider();

    //driverdb= Driver.fromJson(await _sharedPrefdb.readDB('userDB'));

    _progressDialog=MyProgressDialog.createProggressDialog(context, 'Conectandose...');


    markerDriver=await createMarkerImageFromAsset('assets/img/moto_iconx2.png');


    fromMarker=await createMarkerImageFromAsset('assets/img/icon_from2.png');
    toMarker=await createMarkerImageFromAsset('assets/img/icon_to2.png');

    checkGPS();

    getDriverInfo();


  }
  
  
  void getClientInfo()async{
    _client=await _clientProvider.getById(_idTravel);
  }
  


  Future<double> calculatePrice()async{
    Prices prices= await _pricesProvider.getAll();
    if(seconds<60) seconds=60;
    if(km==0) km=1;
    int min=seconds~/60;
    print('================= MIN TOTALES ===============');
    print(min.toString());
    print('================= MIN TOTALES ===============');
    print(km.toString());

    double priceMin= min * prices.min;
    double priceKm= min * prices.km;
    double total=priceKm+priceMin;
    if(total<prices.minValue ){
      total= prices.minValue;
    }

    print('===================== TOTAL =========================');
    print(total.toString());
    return total;
  }
  
  
  void startTimer(){
    _timer=Timer.periodic(Duration(seconds: 1), (timer) {
      seconds=timer.tick;
      min=seconds/60;
      seg=(seconds%60)*60;

      refresh();
    });
  }


  void isCloseToPickupPosition(LatLng from, LatLng to){
    _distaceBetween=Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude
    );


    print('-----------DISTANCE: $_distaceBetween------------');

  }
  void isCloseToNotificationPosition(LatLng from, LatLng to){
    _distaceBetween=Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude
    );

      if(_distaceBetween<=100 && isNotificate==false){
        isNotificate=true;

        print(_client.token);
        _sendClientNotification(_client.token);
        print('Se mando la notificacion');}







  }



  void updateStatus(){
    if(travelInfo.status=='accepted'){
      startTravel();
    }else if(travelInfo.status=='started'){
      finishTravel();
    }
  }


  void startTravel()async{
    if(_distaceBetween<=100){
      Map<String,dynamic> data = {
        'status':'started'
      };
      await _travelInfoProvider.update(data, _idTravel);
      travelInfo.status='started';
      currentStatus='Finalizar Viaje';
      colorStatus=Colors.cyan;

      polylines={};
      points= [];
      //markers.remove(markers['from']);
      markers.removeWhere((key, marker) => marker.markerId.value=='from');
      addSimpleMarker(
          'to',
          travelInfo.toLat,
          travelInfo.toLng,
          'Destino',
          '',
          toMarker
      );
      LatLng from = new LatLng(_position.latitude,_position.longitude);
      LatLng to = new LatLng(travelInfo.toLat,travelInfo.toLng);
      setPolylines(from, to);
      startTimer();
      refresh();

    }else {
      utils.Snackbar.showSnackbar(context, key, 'Debes estar cerca a la posicion del cliente para iniciar el viaje');
    }

    refresh();
  }


  void finishTravel()async{
    _timer?.cancel();

    double total = await calculatePrice();


    saveTravelHistory(total);




  }


  void saveTravelHistory(double price)async{
    TravelHistory travelHistory =new TravelHistory(
      from: travelInfo.from,
      to: travelInfo.to,
      idDriver: _authProvider.getUser().uid,
      idClient: _idTravel,
      idClientDB: _idClientDB,
      idDriverDB:driverdb.id,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      price: price
    );
    String id =await _travelHistoryProvider.create(travelHistory);
    Map<String, dynamic> data = {
      'status': 'finished',
      'idTravelHistory':id,
      'price':price

    };
    await _travelInfoProvider.update(data, _idTravel);
    //saveTravelHistoryDB(id, price);

    travelInfo.status = 'finished';

    Navigator.pushNamedAndRemoveUntil(context, 'driver/travel/calification', (route) => false,arguments: id);

  }

  void saveTravelHistoryDB(String id,double price)async{
    TravelHistory docu =await _travelHistoryProvider.getByIdDB(id);
    TravelHistory travelHistoryDB =new TravelHistory(
        from: docu.from,
        to: docu.to,
        idClientDB: _idClientDB,
        idDriverDB:driverdb.id,
        nameDriver:driverdb.username,
        id_firebase: id,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        price: price
    );
    await _travelHistoryProvider.createDB(travelHistoryDB);

  }



  void _getTravelInfo()async{
    travelInfo=await _travelInfoProvider.getById(_idTravel);
    LatLng from=new LatLng(_position.latitude, _position.longitude);
    LatLng to=new LatLng(travelInfo.fromLat, travelInfo.fromLng);
    addSimpleMarker('to', to.latitude, to.latitude, 'Recoger Aqui', '', fromMarker);
    setPolylines(from, to);
    getClientInfo();



  }

  void getDriverInfo() {
    Stream<DocumentSnapshot> driverStream=_driverProvider.getByidStream(_authProvider.getUser().uid);
    _driverInfoSuscription= driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data());
      refresh();
    });
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
    }


    void checkGPS() async {
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (isLocationEnabled) {
        print('GPS activado');
        updateLocation();
      } else {
        print('GPS desactivado');
        bool locationGPS = await location.Location().requestService();
        if (locationGPS) {
          updateLocation();
          print('ACTIVO EL GPS');
        }
      }
    }


    void saveLocation() async {
      await _geofireProvider.createWorking(
          _authProvider
              .getUser()
              .uid,
          _position.latitude,
          _position.longitude
      );
      _progressDialog.hide();
    }


    void updateLocation() async {
      try {
        await _determinePosition();
        _position = await Geolocator.getLastKnownPosition();
        _getTravelInfo();
        centerPosition();
        saveLocation();
        addMarker('driver',
            _position.latitude,
            _position.longitude,
            'Tu posicion',
            '',
            markerDriver
        );
        refresh();


        _positionStream = Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.best,
                distanceFilter: 1)
        ).listen((Position position) {
          if(travelInfo?.status=='started'){
            mt=mt+Geolocator.distanceBetween(
                _position.latitude,
                _position.longitude,
                position.latitude,
                position.longitude
            );
            km=mt/1000;

          }
          //actualizar posicion en tiempo real
          _position = position;

          addMarker('driver',
              _position.latitude,
              _position.longitude,
              'Tu posicion',
              '',
              markerDriver
          );

          animateCamaraToPosition(_position.latitude, _position.longitude);
          if(travelInfo.fromLat!=null&&travelInfo.fromLng!=null){
            LatLng from=new LatLng(_position.latitude,_position.longitude);
            LatLng to=new LatLng(travelInfo.fromLat,travelInfo.fromLng);

            isCloseToPickupPosition(from,to);
            isCloseToNotificationPosition(from, to);

            
          }

          saveLocation();
          refresh();
        });
      }
      catch (error) {
        print('Error en la localizacion: $error');
      }
    }


  void openBottomSheet() {
    if (_client == null) return;

    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetDriverInfo(
          imageUrl: _client?.image,
          username: _client?.username,
          email: _client?.email,
        )
    );
  }


  void centerPosition() {
      if (_position != null) {
        animateCamaraToPosition(_position.latitude, _position.longitude);
      } else {
        utils.Snackbar.showSnackbar(
            context, key, 'Activa el GPS para obtener la posición');
      }
    }


    Future<Position> _determinePosition() async {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition();
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


    Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
      ImageConfiguration configuration = ImageConfiguration();
      BitmapDescriptor bitmapDescritor =
      await BitmapDescriptor.fromAssetImage(configuration, path);
      return bitmapDescritor;
    }


    void addMarker(String markerId,
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
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          rotation: _position.heading

      );

      markers[id] = marker;
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
      _positionStream?.cancel();
      _statusSuscription?.cancel();
      _driverInfoSuscription?.cancel();
      _timer?.cancel();
    }


  void _sendClientNotification(String token){

    _pushNotificationProvider.sendMessageClient(token,'Alerta de Servicio','Tu conductor ha llegado');

  }
  }



