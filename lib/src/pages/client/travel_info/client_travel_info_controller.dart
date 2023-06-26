
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mi_flutter/src/api/environment.dart';
import 'package:mi_flutter/src/models/directions.dart';
import 'package:mi_flutter/src/models/prices.dart';
import 'package:mi_flutter/src/providers/google_provider.dart';
import 'package:mi_flutter/src/providers/prices_provider.dart';

class ClientTravelInfoController{



  GoogleProvider _googleProvider;
  PricesProvider _pricesProvider;


  Function refresh;
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();
  CameraPosition initialPosition= CameraPosition(
      target: LatLng(-17.9786841,-67.1066987),
      zoom: 14.0
  );
  Map<MarkerId,Marker> markers = <MarkerId,Marker>{};

  String from;
  String to;
  LatLng fromLatLng;
  LatLng toLatLng;

  Set<Polyline> polylines= <Polyline>{};
  //List<LatLng> points = new List.empty(growable: true);
  List<LatLng> points =  [];
  PolylinePoints polylinePoints = PolylinePoints();

  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;

  Direction _directions;
  String km;
  String min;

  double minTotal;
  double maxTotal;


  Future init(BuildContext context,Function refresh )async{


    this.context =context;
    this.refresh=refresh;

    Map<String, dynamic> arguments= ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
    from=arguments['from'];
    to=arguments['to'];
    fromLatLng=arguments['fromLatLng'];
    toLatLng=arguments['toLatLng'];

    _googleProvider = new GoogleProvider();
    _pricesProvider= new PricesProvider();




    fromMarker=await createMarkerImageFromAsset('assets/img/icon_from2.png');
    toMarker=await createMarkerImageFromAsset('assets/img/icon_to2.png');
    animateCamaraToPosition(fromLatLng.latitude, fromLatLng.longitude);
    getGoogleMapsDirections(fromLatLng, toLatLng);


  }


  void getGoogleMapsDirections(LatLng from, LatLng to) async{
    _directions= await _googleProvider.getGoogleMapsDirections(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude
    );
    min=_directions.duration.text;
    km=_directions.distance.text;
    print('Km: $km');
    print('Min: $min');
    calculatePrice();
    refresh();


  }

  void goToRequest(){
    Navigator.pushNamed(context, 'client/travel/request',arguments:{
      'from':from,
      'to':to,
      'fromLatLng':fromLatLng,
      'toLatLng':toLatLng,
    });
  }


  void calculatePrice() async {
    Prices prices = await _pricesProvider.getAll();
    double kmValue=double.parse(km.split(" ")[0]) *prices.km;
    double minValue=double.parse(min.split(" ")[0]) * prices.min;
    double total=kmValue + minValue;
    minTotal=total-0.5;
    maxTotal=total+0.5;

    refresh();


  }

  void calculatePriceSection()async{
    double kmValue=double.parse(km.split(" ")[0]);
    if(kmValue<=5){minTotal=5; maxTotal=5;}
    if(kmValue>5||kmValue<=8){minTotal=10; maxTotal=10;}
    if(kmValue<8){minTotal=15; maxTotal=15;}

}


  Future<void> setPolylines() async{
    print('====================polylines');
    PointLatLng pointFromLatLng =PointLatLng(fromLatLng.latitude, fromLatLng.longitude);
    PointLatLng pointToLatLng =PointLatLng(toLatLng.latitude, toLatLng.longitude);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Environment.API_KEY_MAPS,
        pointFromLatLng,
        pointToLatLng
    );
    for(PointLatLng point in result.points){
      points.add(LatLng(point.latitude, point.longitude));

    }
    Polyline polyline=Polyline(
        polylineId: PolylineId('poly'),
      color: Colors.amber,
      points: points,
      width: 6
    );
    polylines.add(polyline);
    addMarker('from', fromLatLng.latitude, fromLatLng.longitude, 'Recoger aqui', '', fromMarker);
    addMarker('to', toLatLng.latitude, toLatLng.longitude, 'Destino', '', toMarker);
    refresh();


  }


  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async{
    ImageConfiguration configuration= ImageConfiguration();
    BitmapDescriptor bitmapDescriptor=
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;

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



    );

    markers[id]=marker;



  }




  Future animateCamaraToPosition(double latitude, double longitude)  async{
    GoogleMapController controller=await _mapController.future;
    if(controller!=null){
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(latitude,longitude),
            zoom: 15,
          )
      ));
    }
  }





  void onMapCreated(GoogleMapController controller) async{
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},{"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#64779e"}]},{"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},{"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#334e87"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#023e58"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#283d6a"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#6f9ba5"}]},{"featureType":"poi","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#023e58"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#3C7680"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#304a7d"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},{"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2c6675"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#255763"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#b0d5ce"}]},{"featureType":"road.highway","elementType":"labels.text.stroke","stylers":[{"color":"#023e58"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},{"featureType":"transit","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"transit.line","elementType":"geometry.fill","stylers":[{"color":"#283d6a"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#3a4762"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1626"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4e6d70"}]}]');
    _mapController.complete(controller);
    await setPolylines();


  }

  void gotoClientMap(){
    Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);

  }

}


