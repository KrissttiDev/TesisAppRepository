import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:mi_flutter/src/pages/login/login_controller.dart';
import 'package:mi_flutter/src/utils/colors.dart' as utils;
import 'package:mi_flutter/src/widgets/button_app.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  LoginController _con =new LoginController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _con.init(context);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
            children: [
              _bannerApp(),
              _textDescription(),
              _textLogin(),
              SizedBox(height: MediaQuery.of(context).size.height*0.17),
              _textFieldEmail(),
              _textFieldPassword(),
              _buttomLogin(),
              _textDontHaveAccount()

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

  Widget _textDescription(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(
        'Continua con tu',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 24,
              fontFamily: 'NimbusSans'


      ),
      ),
    );
  }

  Widget _textLogin(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        'Login',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 28,

        ),


      ),
    );
  }


  Widget _buttomLogin(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
        onPressed: _con.loginDB,
        text: 'Iniciar Sesion',
        color: utils.Colors.uberCloneColor,
        textColor: Colors.white,
        ),
    );
  }
  Widget _textDontHaveAccount(){
    return GestureDetector(
      onTap: _con.goToRegisterPage,
      child: Container(


        margin: EdgeInsets.only(bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '¿No tienes cuenta?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,

              ),
            ),
            Text(
              'Registrate',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
              ),
            ),
          ],
        ),


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





}
