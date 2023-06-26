import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_for_flutter/google_places_for_flutter.dart';
import 'package:location/location.dart'as location;
import 'package:mi_flutter/src/api/environment.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/order.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/providers/orders_provider.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ClientOrdersMapController {
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  Position _position;


  String addressName;
  LatLng addressLatLng;

  
  CameraPosition initialPosition=CameraPosition(
      target: LatLng(-17.9703222,-67.1002264),
    zoom: 14
  );

  Completer<GoogleMapController> _mapController= Completer();
  BitmapDescriptor deliveryMarker;
  BitmapDescriptor homeMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Order order;

  Set<Polyline> polylines={};
  List<LatLng> points=[];

  OrdersProvider _ordersProvider=new OrdersProvider();
  Client clientDB;
  SharedPref _sharedPrefDB = new SharedPref();
  double _distanceBetween;
  IO.Socket socket;



  Future init(BuildContext context, Function refresh)async{
    this.context=context;
    this.refresh=refresh;
    order=Order.fromJson(ModalRoute.of(context).settings.arguments as Map<String,dynamic>);
    print(order?.address?.neighborhood);
    print(order?.address?.address);
    deliveryMarker= await createMarkerFromAsset('assets/img/delivery_2x.png');
    homeMarker= await createMarkerFromAsset('assets/img/home.png');

    socket = IO.io('http://${Environment.API_DELIVERY}/orders/delivery', <String, dynamic> {
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket?.connect();
    socket.on('position/${order.id}', (data) {
      print(data);
      addMarker(
          'delivery',
          data['lat'],
          data['lng'],
          'Tu repartidor',
          '',
          deliveryMarker
      );
    });

    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));
    _ordersProvider.init(context, clientDB);

    print('ORDEN: ${order.toJson()}');
    checkGPS();



  }

  void isCloseToDeliveryPosition(){
    _distanceBetween=Geolocator.distanceBetween(
        _position.latitude,
        _position.longitude,
        order.address.lat,
        order.address.lng
    );

    print('--------------Distancia ${_distanceBetween}---------------');

  }









  Future<void> setPolylines(LatLng from, LatLng to)async{
    PointLatLng pointFrom=PointLatLng(from.latitude, from.longitude);
    PointLatLng pointTo=PointLatLng(to.latitude, to.longitude);
    PolylineResult result=await PolylinePoints().getRouteBetweenCoordinates(
        Environment.API_KEY_MAPS,
        pointFrom,
        pointTo
    );
    for(PointLatLng point in result.points){
      points.add(LatLng(point.latitude, point.longitude));
    }
    Polyline polyline=Polyline(
        polylineId: PolylineId('poly'),
        color: Colors.red[600],
      points: points,
      width: 6
    );
    polylines.add(polyline);


    refresh();

  }


  void call()async{
    //launchUrl("tel://${order.client.phone}");
    final Uri launchUri=Uri(
      scheme: 'tel',
      path: order?.client?.phone
    );
    launchUrl(launchUri);

  }



  void addMarker(
      markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
      ){
    
    MarkerId id= MarkerId(markerId);
    Marker marker= Marker(
        markerId: id,
      icon:iconMarker,
      position: LatLng(lat,lng),
      infoWindow: InfoWindow(title: title,snippet: content),
    );

    markers[id]=marker;
    refresh();


  }

  Future<Null> setLocationDraggableInfo()async{
    if(initialPosition!=null){
      double lat= initialPosition.target.latitude;
      double lng= initialPosition.target.longitude;

      List<Placemark> address=await placemarkFromCoordinates(lat, lng);

      if(address!=null){
        if(address.length>0){
          String direction=address[0].thoroughfare;
          String street=address[0].subThoroughfare;
          String city=address[0].locality;
          String departament=address[0].administrativeArea;
          String country=address[0].country;
          addressName='$direction#$street#$city#$departament';
          addressLatLng=new LatLng(lat, lng);

          print('LAT: ${addressLatLng.latitude}');
          print('LNG: ${addressLatLng.longitude}');

          refresh();
        }
      }


    }
  }


  void selectedRefPoint(){
    Map<String,dynamic> data={
      'address':addressName,
      'lat':addressLatLng.latitude,
      'lng':addressLatLng.longitude
    };
    Navigator.pop(context,data);
  }

  Future<BitmapDescriptor> createMarkerFromAsset(String path)async{
    ImageConfiguration configuration= ImageConfiguration();
    BitmapDescriptor descriptor = await BitmapDescriptor.fromAssetImage(configuration, path);
    return descriptor;

  }

  void onMapCreate(GoogleMapController controller){
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#f5f5f5"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},{"featureType":"road.arterial","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9c9c9"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]}]');
    _mapController.complete(controller);
  }

  void dispose(){

    socket?.disconnect();
  }

  void updateLocation()async{
    try{
      await _determinePosition(); //obtener la posiscion y permisos
      _position=await Geolocator.getLastKnownPosition();
      animatedCameraToPosition(order.lng, order.lng);

      addMarker(
          'delivery',
          order.lat,
          order.lng,
          'Tu repartidor',
          '',
          deliveryMarker
      );

      addMarker(
          'Home',
          order.address?.lat,
          order.address?.lng,
          'Lugar de entrega',
          '',
          homeMarker
      );
      
      LatLng from= new LatLng(order.lat, order.lng);
      LatLng to= new LatLng(order.address.lat, order.address.lng);
      setPolylines(from, to);
      refresh();



    }
    catch(e){
      print('Error: $e');
    }
  }

  void checkGPS()async{
    bool isLocationEnable=await Geolocator.isLocationServiceEnabled();
    if(isLocationEnable){
      updateLocation();
    }else{
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        updateLocation();
      }
    }

  }

  Future animatedCameraToPosition(double lat, double lng) async{
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(lat,lng),
          zoom: 15,
          bearing: 0
        )
    ));
  }

  void centerPosition(){
    if(_position!=null){
      animatedCameraToPosition(_position.latitude, _position.longitude);


    } else{
      utils.Snackbar.showSnackbar(context,key,'Activa el GPS para obtener la posición');

    }
  }



  Future<Position> _determinePosition() async {

    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }



}
