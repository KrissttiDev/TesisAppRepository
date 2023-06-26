import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mi_flutter/src/pages/client/address/create/client_address_create_controller.dart';


class ClientAddressCreatePage extends StatefulWidget {
  const ClientAddressCreatePage({Key key}) : super(key: key);

  @override
  _ClientAddressCreatePageState createState() => _ClientAddressCreatePageState();
}

class _ClientAddressCreatePageState extends State<ClientAddressCreatePage> {


  ClientAddressCreateController _con = new ClientAddressCreateController();

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
        title:  Text(
          'Nueva direcciòn',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: _buttonAccept(),
      body: Column(
          children: [
            _textCompleteData(),
            _textFieldAddress(),
            _textFieldNeighborhood(),
            _textFieldRefPoint(),
          ],
        ),


    );
  }

  Widget _textFieldAddress(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
      child: TextField(
        controller: _con.addressController,

        decoration: InputDecoration(
          labelText: 'Dirección',
          suffixIcon: Icon(
            Icons.location_on,
            color: Colors.red[600],
          ),
        ),
      ),
    );
  }

  Widget _textFieldRefPoint(){
    return  Container(
        margin: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
        child: TextField(
          controller: _con.refPointController,
          onTap: _con.openMap,
          autofocus: false,
          focusNode: AlwaysDisableFocusNode(),
          decoration: InputDecoration(
            labelText: 'Punto de referencia',
            suffixIcon: Icon(
              Icons.map,
              color: Colors.red[600],
            ),
          ),
        ),
      );
  }

  Widget _textFieldNeighborhood(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
      child: TextField(
        controller: _con.neighborhoodController,
        decoration: InputDecoration(
          labelText: 'Barrio',
          suffixIcon: Icon(
            Icons.location_city,
            color: Colors.red[600],
          ),
        ),
      ),
    );
  }




  Widget _buttonAccept(){
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 30,horizontal: 50),
      child: ElevatedButton(

        onPressed: _con.createAddress,
        child: Text(
          'CREAR DIRECCION',
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


  Widget _textCompleteData(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 40,vertical: 30),
      child: Text(
        'Completa estos datos',
        style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold

        ),
      ),
    );
  }


  void refresh(){
    setState(() {

    });
  }
}


class AlwaysDisableFocusNode extends FocusNode{
  @override
  bool get hasFocus => false;
}