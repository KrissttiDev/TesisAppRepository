import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mi_flutter/src/pages/client/address/map/client_address_map_controller.dart';

import 'package:mi_flutter/src/widgets/no_data_widget.dart';


class ClientAddressMapPage extends StatefulWidget {
  const ClientAddressMapPage({Key key}) : super(key: key);

  @override
  _ClientAddressMapPageState createState() => _ClientAddressMapPageState();
}

class _ClientAddressMapPageState extends State<ClientAddressMapPage> {


  ClientAddressMapController _con = new ClientAddressMapController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        title: Text('Ubica tu direccion en el mapa'),


      ),
      body: Stack(
        children: [
          _googleMaps(),
          Container(
            alignment: Alignment.center,
            child: _iconMyLocation(),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            alignment: Alignment.topCenter,
            child: _cardAddress(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: _buttonAccept(),
          )
        ],
      ),

    );
  }

  Widget _buttonAccept(){
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 30,horizontal: 70),
      child: ElevatedButton(

        onPressed: _con.selectedRefPoint,
        child: Text(
          'Selecionar este punto',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15

          ),
        ),
        style: ElevatedButton.styleFrom(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),

          ),
          primary: Colors.red[600],
        ),
      ),
    );
  }



  Widget _cardAddress(){
    return Container(
      child: Card(
        color: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: Text(

            _con.addressName ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold
            ),

          ),
        ),
      ),
    );
  }

  Widget _iconMyLocation(){
    return Image.asset(
        'assets/img/my_location_delivery.png',
      height: 65,
      width: 65,
    );
  }

  Widget _googleMaps(){
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreate,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      onCameraMove: (position){
        _con.initialPosition=position;
      },
      onCameraIdle:  () async{
        await _con.setLocationDraggableInfo();
      },
    );

  }




  void refresh(){
    setState(() {

    });
  }
}
