

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

import 'package:mi_flutter/src/pages/client/edit/client_edit_controller.dart';
import 'package:mi_flutter/src/utils/colors.dart' as utils;
import 'package:mi_flutter/src/widgets/button_app.dart';
class ClientEditPage extends StatefulWidget {
  const ClientEditPage({Key key}) : super(key: key);

  @override
  _ClientEditPageState createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {

  ClientEditController _con =new ClientEditController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _con.init(context,refresh);
    });


  }


  @override
  Widget build(BuildContext context) {

    print('METODO BUILD');


    return Scaffold(
      key: _con.key,
      appBar: AppBar(),
      bottomNavigationBar: _buttomRegister(),
      body: SingleChildScrollView(
        child: Column(
            children: [
              _bannerApp(),
              _textLogin(),
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              _textFieldUsername(),
              _textFieldLastname(),
              _textFieldPhone()

            ],
          ),
        ),
      );
  }



  Widget _bannerApp(){
    return ClipPath(

      clipper: WaveClipperTwo(),
      child: Container(
        color: utils.Colors.uberCloneColor,
        height:MediaQuery.of(context).size.height*0.22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
             GestureDetector(
               onTap: _con.showAlertDialog,
               child: CircleAvatar(
                 backgroundImage: _con.imageFile != null ?
                 FileImage(_con.imageFile) :
                 _con.clientDB?.image != null
                     ? NetworkImage(_con.clientDB?.image)
                     : AssetImage(_con.imageFile?.path ?? 'assets/img/uber_profile.jpg'),
                 radius: 50,
               ),

             ),


            Container(
              //margin: EdgeInsets.only(top: 10),
              child: Text(
                _con.client?.email??'',
                style:  TextStyle(
                    fontFamily: 'Pacifico',
                    height: 4,
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700
                ),
              ),
            )
          ],
        ),
      ),
    );

  }



  Widget _textLogin(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Text(
        'Editar Perfil',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 25,

        ),


      ),
    );
  }


  Widget _buttomRegister(){
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
        onPressed: _con.updateBdd,
        text: 'Actualizar Ahora',
        color: utils.Colors.uberCloneColor,
        textColor: Colors.white,
        ),
    );
  }






  Widget _textFieldUsername(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.usernameController,
        decoration: InputDecoration(
            hintText: 'Juanito Alcachofa',
            labelText: 'Nombre',
            suffixIcon: Icon(
              Icons.person_outline,
              color: utils.Colors.uberCloneColor,
            )

        ),
      ),
    );
  }

  Widget _textFieldLastname(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.lastnameController,
        decoration: InputDecoration(
            hintText: ' Alcachofa',
            labelText: 'Apellidos',
            suffixIcon: Icon(
              Icons.person_outline,
              color: utils.Colors.uberCloneColor,
            )

        ),
      ),
    );
  }

  Widget _textFieldPhone(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.phoneController,
        decoration: InputDecoration(

            labelText: 'Teléfono',
            suffixIcon: Icon(
              Icons.phone,
              color: utils.Colors.uberCloneColor,
            )

        ),
      ),
    );
  }



  void refresh(){
    setState(() {});
  }






}
