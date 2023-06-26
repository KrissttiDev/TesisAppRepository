import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';


import 'package:mi_flutter/src/pages/client/register/client_register_controller.dart';
import 'package:mi_flutter/src/utils/colors.dart' as utils;
import 'package:mi_flutter/src/widgets/button_app.dart';
class ClientRegisterPage extends StatefulWidget {
  const ClientRegisterPage({Key key}) : super(key: key);

  @override
  _ClientRegisterPageState createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends State<ClientRegisterPage> {

  ClientRegisterController _con =new ClientRegisterController();
  //ClientRegisterDBController _cun = new ClientRegisterDBController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        //_con.init(context);
        _con.init(context);


    });
  }

  @override
  Widget build(BuildContext context) {

    print('METODO BUILD');

    return Scaffold(
      key: _con.key,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
            children: [
              _bannerApp(),

              _textLogin(),
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              _textFieldUsername(),
              _textFieldLastname(),
              _textFieldEmail(),
              _textFieldPhone(),
              _textFieldPassword(),
              _textFieldConfirmPassword(),
              _buttomRegister(),


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
            Image.asset(
              'assets/img/logo_app2.1.png',
              width: 180,
              height: 100,
            ),
            Text(
              'Facil y Rápido',
              style:  TextStyle(
                  fontFamily: 'Pacifico',
                  height: 4,
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w700
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
        'Registro',
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
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
        onPressed: _con.register,
        text: 'Registrar Ahora',
        color: utils.Colors.uberCloneColor,
        textColor: Colors.white,
        ),
    );
  }



  Widget _textFieldEmail(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.emailController,
        decoration: InputDecoration(
          hintText: 'Correo@gmail.com',
            labelText: 'Correo Electronico',
          suffixIcon: Icon(
            Icons.alternate_email_outlined,
                color: utils.Colors.uberCloneColor,
          )

        ),
      ),
    );
  }


  Widget _textFieldUsername(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.usernameController,
        decoration: InputDecoration(
            hintText: 'Juanito ',
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


  Widget _textFieldPassword(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: TextField(
        obscureText: true,
        controller: _con.passwordController,
        decoration: InputDecoration(
            labelText: 'Contraseña',
          suffixIcon: Icon(
            Icons.lock_open_outlined,
                color: utils.Colors.uberCloneColor,
          )
        ),
      ),
    );
  }


  Widget _textFieldConfirmPassword(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: TextField(
        obscureText: true,
        controller: _con.confirmpasswordController,
        decoration: InputDecoration(
            labelText: 'Confirmar Contraseña',
            suffixIcon: Icon(
              Icons.lock_open_outlined,
              color: utils.Colors.uberCloneColor,
            )
        ),
      ),
    );
  }





}
