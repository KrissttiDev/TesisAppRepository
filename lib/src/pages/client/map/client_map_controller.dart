import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoder_krutus/models.dart';

//import 'package:geocode/geocode.dart';
import 'package:location_geocoder/location_geocoder.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/src/places.dart';


import 'package:location/location.dart' as location;
import 'package:mi_flutter/src/api/environment.dart';


import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/client_provider.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:mi_flutter/src/providers/geofire_provider.dart';
import 'package:mi_flutter/src/providers/push_notification_provider.dart';
import 'package:mi_flutter/src/utils/my_progress_dialog.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:google_maps_webservice_ex/places.dart'as places;
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_geocoder_krutus/google_geocoder_krutus.dart';








class ClientMapController{
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
  ClientProvider _clientProvider;
  PushNotificationProvider _pushNotificationProvider;

  bool isConnect=false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot<Object>> _statusSuscription;
  StreamSubscription<DocumentSnapshot<Object>> _clientInfoSuscription;

  SharedPref _sharedPref;
  SharedPref _sharedPrefDB;


  Client client;
  Client clientDB;


  String from;
  LatLng fromLatLng;


  String to;
  LatLng toLatLng;


  bool isFromSelected=true;
  //GeoCode geoCode = GeoCode();
  places.GoogleMapsPlaces _places =places.GoogleMapsPlaces(apiKey: Environment.API_KEY_MAPS);
  final LocatitonGeocoder geocoder = LocatitonGeocoder(Environment.API_KEY_MAPS);
  //FlutterGooglePlacesSdk _places;

  //GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Environment.API_KEY_MAPS);










  Future init(BuildContext context, Function  refresh) async{
    this.context=context;
    this.refresh=refresh;
    _geofireProvider=new GeofireProvider();
    _authProvider=new AuthProvider();
    _driverProvider= new DriverProvider();
    _clientProvider=new ClientProvider();
    _pushNotificationProvider=new PushNotificationProvider();

    _sharedPref=new SharedPref();
    _sharedPrefDB=new SharedPref();
    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));








    _progressDialog=MyProgressDialog.createProggressDialog(context, 'Conectandose...');
    markerDriver=await createMarkerImageFromAssst('assets/img/icon_biker4.png');

    checkGPS();
    saveToken();
    getClientInfo();


  }

  void getClientInfo() {
    Stream<DocumentSnapshot> clientStream=_clientProvider.getByidStream(_authProvider.getUser().uid);
    _clientInfoSuscription= clientStream.listen((DocumentSnapshot document) {
      client = Client.fromJson(document.data());
      refresh();
    });
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


    }else{
      print('GPS desactivado');
      bool locationGPS= await location.Location().requestService();
      if(locationGPS){
        updateLocation();

        print('ACTIVO EL GPS');
      }
    }
  }





  void updateLocation() async {
    try{
      await _determinePosition();
      _position=await Geolocator.getLastKnownPosition();


      centerPosition();
      getNearbyDrivers();


    }
    catch(error){
      print('Error en la localizacion: $error');

    }
  }

  void requestDriver(){
    if(fromLatLng!=null && toLatLng!=null) {
      Navigator.pushNamed(context, 'client/travel/info',arguments:{
        'from':from,
        'to':to,
        'fromLatLng':fromLatLng,
        'toLatLng':toLatLng,
      });

    }else{
      utils.Snackbar.showSnackbar(context, key, 'Selecciona el lugar de recogida y destino');
    }

  }

  void changeFromTo(){
    isFromSelected=!isFromSelected;
    if(isFromSelected) {
      utils.Snackbar.showSnackbar(context, key, 'Estas Seleccionando el lugar de recogida');
    }else{
      utils.Snackbar.showSnackbar(context, key, 'Estas Seleccionando el lugar de destino');

    }
  }


  Future<Null> showGoogleAutoComplete(bool isFrom) async {
    Prediction p =await PlacesAutocomplete.show(
        context: context,
        apiKey: Environment.API_KEY_MAPS,
        language: 'es',
      //strictbounds: true,
      //-17.9805658,-67.1077779
      radius: 8000,
     //location:
    );




    if (p != null) {
      places.PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId,language: 'es');
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      print(lat);
      print(lng);


      if (detail != null) {

        if (isFrom) {
          from = p.description;
          fromLatLng = new LatLng(lat, lng);
        }
        else {
          to = p.description;
          toLatLng = new LatLng(lat, lng);
        }

        refresh();
      }



      /*
      if (address != null) {

        if (address.toString().length>0) {

          if (detail != null) {
            String direction = detail.result.name;
            String city = address.city;
            print(city);
            String department = address.state;
            print(department);

            if (isFrom) {
              from = '$direction, $city, $department';
              fromLatLng = new LatLng(lat, lng);
            }
            else {
              to = '$direction, $city, $department';
              toLatLng = new LatLng(lat, lng);
            }

            refresh();
          }
        }
      }*/


    }



  }






  Future<Null> setLocationDraggableInput()async{
    if(initialPosition!=null){
      double lat=initialPosition.target.latitude;
      double lng=initialPosition.target.longitude;

      List<Placemark> address =await placemarkFromCoordinates(lat,lng);

      if(address!=null){
        if(address.length>0){
          String direction=address[0].thoroughfare;
          String street=address[0].subThoroughfare;
          String city=address[0].locality;
          String departament=address[0].administrativeArea;
          String country=address[0].country;

          if(isFromSelected){
            from='$direction #$street, $city, $departament';

            fromLatLng=new LatLng(lat,lng);
            print('===============================================');
            print(fromLatLng);


          }
          else{
            to='$direction #$street, $city, $departament';
            toLatLng=new LatLng(lat,lng);
            print('===============================================');
            print(toLatLng);


          }
          refresh();

        }
      }

    }
  }


  void saveToken(){
    _pushNotificationProvider.saveToken(_authProvider.getUser().uid, 'client');
  }


  void goToEditPage(){
    print(clientDB.session_token);
    Navigator.pushNamed(context, 'client/edit');
  }

  void goToHistoryPage(){
    Navigator.pushNamed(context, 'client/history', );
  }






  void getNearbyDrivers() async{
    Stream<List<DocumentSnapshot>> stream=
    _geofireProvider.getNearbyDrivers(
        _position.latitude,
        _position.longitude,
        10);
    stream.listen((List<DocumentSnapshot> documentList) {

      for(MarkerId m in markers.keys){
        bool remove=true;

        for(DocumentSnapshot d in documentList){
          if(m.value==d.id){
            remove =false;
          }
        }
        if(remove){
          markers.remove(m);
          refresh();
        }
      }

      for(DocumentSnapshot<Map<String,dynamic>> d in documentList){
        GeoPoint point = d.data()['position']['geopoint'];
        addMarker(
            d.id,
            point.latitude,
            point.longitude,
            'Conductor disponible',
            d.id,
            markerDriver
        );
      }
      refresh();

    });
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
            zoom: 14,
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
  void goToRoles() {
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }


  void dispose(){//metodo que elimina los listen para que la app no sea tan pesada
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _clientInfoSuscription?.cancel();

  }

  void singOut() async{



    await _clientProvider.logoutDB(clientDB.id);
    await _authProvider.singOut();
    await _sharedPrefDB.removeDB('userDB');
   
    //await _clientProvider.logoutDB(clientDB.id);


    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);

  }

  void goToPlacesD(){
    Navigator.pushNamed(context, 'client/places');
  }


}