import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:mi_flutter/src/providers/geofire_provider.dart';
import 'package:mi_flutter/src/utils/my_progress_dialog.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mi_flutter/src/models/driver.dart';

import '../../../providers/push_notification_provider.dart';
import '../../../utils/share_pref.dart';

class DriverMapController{

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();


  CameraPosition initialPosition= CameraPosition(
      target: LatLng(-17.9786841,-67.1066987),
    zoom: 14.0
  );

  Map<MarkerId,Marker> markers = <MarkerId,Marker>{};
  Position _position;
  StreamSubscription<Position> _positionStream;
  BitmapDescriptor markerDriver;

  GeofireProvider _geofireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  PushNotificationProvider _pushNotificationProvider;

  bool isConnect=false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot<Object>> _statusSuscription;
  StreamSubscription<DocumentSnapshot<Object>> _driverInfoSuscription;


  Driver driver;
  Driver driverdb;

  Timer _timer;

  SharedPref _sharedPrefdb;







  Future init(BuildContext context, Function  refresh) async{
    this.context=context;
    this.refresh=refresh;
    _geofireProvider=new GeofireProvider();
    _authProvider=new AuthProvider();
    _driverProvider= new DriverProvider();
    _pushNotificationProvider=new PushNotificationProvider();
    _sharedPrefdb=new SharedPref();
    
    _progressDialog=MyProgressDialog.createProggressDialog(context, 'Conectandose...');
    markerDriver=await createMarkerImageFromAssst('assets/img/moto_iconx2.png');
     driverdb= Driver.fromJson(await _sharedPrefdb.readDB('userDB'));
    print(driverdb.roles.length);
    

    checkGPS();
    saveToken();
    getDriverInfo();


  }
  
  void getDriverInfo() {
    Stream<DocumentSnapshot> driverStream=_driverProvider.getByidStream(_authProvider.getUser().uid);
    _driverInfoSuscription= driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data());
      refresh();
    });
  }



  void saveToken(){
    _pushNotificationProvider.saveToken(_authProvider.getUser().uid, 'driver');
  }




  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},{"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#64779e"}]},{"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},{"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#334e87"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#023e58"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#283d6a"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#6f9ba5"}]},{"featureType":"poi","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#023e58"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#3C7680"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#304a7d"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},{"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2c6675"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#255763"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#b0d5ce"}]},{"featureType":"road.highway","elementType":"labels.text.stroke","stylers":[{"color":"#023e58"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},{"featureType":"transit","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"transit.line","elementType":"geometry.fill","stylers":[{"color":"#283d6a"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#3a4762"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1626"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4e6d70"}]}]');
    _mapController.complete(controller);
  }


  void checkGPS() async{
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(isLocationEnabled) {
      print('GPS activado');
      updateLocation();
      checkIfIsConnect();

    }else{
      print('GPS desactivado');
      bool locationGPS= await location.Location().requestService();
      if(locationGPS){
        updateLocation();
        checkIfIsConnect();
        print('ACTIVO EL GPS');
      }
    }
  }


  void saveLocation() async{
    await _geofireProvider.create(
        _authProvider.getUser().uid,
        _position.latitude,
        _position.longitude
    );
    _progressDialog.hide();
  }

  void startTimer() {
    _timer = Timer(Duration(minutes: 15), () {
      // Código que se ejecutará después de 15 minutos
      disconnect();
    });
  }
  void cancelTimer() {
    if (_timer != null) {
      _timer?.cancel();
    }
  }


  void connect(){
    if(isConnect){

      disconnect();
    }else{
      _progressDialog.show();
      updateLocation();
      startTimer();
    }

  }
  void disconnect(){
    _positionStream?.cancel(); //? para que el objeto no venga en nulo
    _geofireProvider.delete(_authProvider.getUser().uid);
  }

  void checkIfIsConnect(){
    Stream<DocumentSnapshot> status =
    _geofireProvider.getLocationByidStream(_authProvider.getUser().uid);
    _statusSuscription= status.listen((DocumentSnapshot document) {
      if(document.exists){
        isConnect=true;
      }else{
        isConnect=false;
      }
      refresh();
    });
  }





  void updateLocation() async {
    try{
      await _determinePosition();
      _position=await Geolocator.getLastKnownPosition(
      );
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


      _positionStream =Geolocator.getPositionStream(
           locationSettings: LocationSettings(
               accuracy: LocationAccuracy.best,
               distanceFilter: 1)
      ).listen((Position position) {
        //actualizar posicion en tiempo real
        _position=position;

        addMarker('driver',
            _position.latitude,
            _position.longitude,
            'Tu posicion',
            '',
            markerDriver
        );

        animateCamaraToPosition(_position.latitude, _position.longitude);
        saveLocation();
        refresh();


      });


    }
    catch(error){
      print('Error en la localizacion: $error');

    }
  }

  void centerPosition(){
    if(_position!=null){
      animateCamaraToPosition(_position.latitude, _position.longitude);
    } else{
      utils.Snackbar.showSnackbar(context,key,'Activa el GPS para obtener la posición');

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

  Future animateCamaraToPosition(double latitude, double longitude)  async{
    GoogleMapController controller=await _mapController.future;
    if(controller!=null){
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(latitude,longitude),
            zoom: 17,
              )
      ));
    }

  }


  Future<BitmapDescriptor> createMarkerImageFromAssst(String path) async{
    ImageConfiguration configuration= ImageConfiguration();
    BitmapDescriptor bitmapDescritor=
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescritor;

  }


  void addMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
      ){
    MarkerId id= MarkerId(markerId);
    Marker marker=Marker(
      markerId: id,
    icon: iconMarker,
    position: LatLng(lat,lng),
      infoWindow: InfoWindow(title: title, snippet: content),
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: Offset(0.5,0.5),
      rotation: _position.heading

    );

    markers[id]=marker;



  }

  void openDrawer(){
    key.currentState.openDrawer();
  }


  void dispose(){//metodo que elimina los listen para que la app no sea tan pesada
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _driverInfoSuscription?.cancel();
    cancelTimer();

  }

  void singOut() async{
    await _authProvider.singOut();
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);

}

  void goToEditPage(){
    Navigator.pushNamed(context, 'driver/edit');
  }







}