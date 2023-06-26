import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:mi_flutter/src/pages/client/map/client_map_controller.dart';
import 'package:mi_flutter/src/widgets/button_app.dart';

class ClientMapPage extends StatefulWidget {


  @override
  _ClientMapPageState createState() => _ClientMapPageState();
}


class _ClientMapPageState extends State<ClientMapPage> {
  TextEditingController controller = TextEditingController();


  ClientMapController _con =new ClientMapController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);

    });
  }

  @override
  void dispose() { //metodo se ejecuta cuadno cierra la pantalla
    // TODO: implement dispose
    super.dispose();
    _con.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      drawer: _drawer(),
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                _buttonDrawer(),
                _cardGooglePlace(),

                _buttonChangeTo(),
                _buttonCenterPosition(),


                Expanded(child: Container()),
                _buttonRequest(),

              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _iconMyLocation(),
          )
        ],
      ),
    );
  }
  
  
  
  Widget _iconMyLocation(){
    return Image.asset(
        'assets/img/my_location2.png',
        height: 65,
        width: 65,
    );

  }

  Widget _drawer(){
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(

                  child: Text(
                    //_con.client?.username ?? 'Nombre de Usuario',
                    _con.clientDB?.username??'Nombre de Usuario',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),


                Container(
                  child: Text(
                    _con.clientDB?.email?? 'Correo Electronico',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 10,),
                CircleAvatar(
                  backgroundImage: _con.clientDB?.image!=null?
                  NetworkImage(_con.clientDB?.image)
                      :AssetImage('assets/img/uber_profile.jpg'),
                  radius: 40,
                ),

              ],
            ),
            decoration: BoxDecoration(
                color: Colors.amber[500]
            ),
          ),
          ListTile(
            title: Text('Editar perfil'),
            trailing: Icon(Icons.edit),
            //leading: Icon(Icons.cancel),
            onTap: _con.goToEditPage,
          ),
          ListTile(
            title: Text('Historial de viajes'),
            trailing: Icon(Icons.timer),
            //leading: Icon(Icons.cancel),
            onTap: _con.goToHistoryPage,
          ),
          /*ListTile(
            title: Text('Selecionar Rol'),
            trailing: Icon(Icons.person_outline),
            //leading: Icon(Icons.cancel),
            onTap: _con.goToRoles,
          ),*/
          ListTile(
            title: Text('Cerrar Sesion'),
            trailing: Icon(Icons.power_settings_new),
            //leading: Icon(Icons.cancel),
            onTap: _con.singOut,
          ),

        ],
      ),
    );
  }



  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: _con.centerPosition,
      child: Container(
        alignment:  Alignment.centerRight,
        margin:  EdgeInsets.symmetric(horizontal: 19),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
                Icons.location_searching,
                color: Colors.grey[400],
                size: 20
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonChangeTo(){
    return GestureDetector(
      onTap: _con.changeFromTo,
      child: Container(
        alignment:  Alignment.centerRight,
        margin:  EdgeInsets.symmetric(horizontal: 19),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
                Icons.refresh,
                color: Colors.grey[400],
                size: 20
            ),
          ),
        ),
      ),
    );
  }



  Widget _buttonDrawer(){
    return Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _con.openDrawer,
        icon: Icon(Icons.menu,color: Colors.white,),

      ),
    );

  }

  Widget _buttonRequest(){
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin:  EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        onPressed: _con.requestDriver,
        text: 'SOLICITAR',
        color: Colors.cyan,
        textColor: Colors.white,

      ),

    );
  }


  Widget _googleMapsWidget(){

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      onCameraMove: (position) {
        _con.initialPosition=position;
        print('on camrera MOVE : $position');
      },
      onCameraIdle: ()async{
        await _con.setLocationDraggableInput();
      },
      //polylines: _con.polylines,

    );
  }




  Widget _cardGooglePlace(){
    return Container(
      width: MediaQuery.of(context).size.width*0.9,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),

        ),


          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _infoCardLocation(
                    'Desde',
                    _con.from ?? 'Lugar de recogida',
                        () async {
                      await _con.showGoogleAutoComplete(true);
                    }
                ),
                SizedBox(height: 5),
                Container(
                  // width: double.infinity,
                    child: Divider(color: Colors.grey, height: 10)
                ),
                SizedBox(height: 5),
                _infoCardLocation(
                    'Hasta',
                    _con.to ?? 'Lugar de destino',
                        () async {
                      await _con.showGoogleAutoComplete(false);
                    }
                ),



              ],
            ),

        ),
      ),
    );
  }




  Widget _infoCardLocation(String title, String value, Function function) {
    return GestureDetector(
      onTap: function,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 10
            ),
            textAlign: TextAlign.start,
          ),
          Text(
            value,
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }



  void refresh(){
    setState(() {


    });
  }







}
