import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:mi_flutter/src/pages/home/home_controller.dart';
import 'package:flutter/scheduler.dart';

class HomePage extends StatefulWidget {


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeController _con=new HomeController();


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
      body:SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.black, Colors.black87]
            )
          ),
          child: Column(
            children: [
              _bannerApp(context),
              SizedBox(height: 50),
              _textSelectYourRoll(),
              SizedBox(height: 30),
              _imageTypeUser(context,'assets/img/cliente2.png','client'),
              SizedBox(height: 10),
              _textTypeUser('Cliente'),
              SizedBox(height: 30),
              _imageTypeUser(context,'assets/img/conductor.png','driver'),
              SizedBox(height: 10),
              _textTypeUser('Conductor')

            ],
          ),
        ),
      ),
    );
  }

//metodos aparte
  Widget _bannerApp(BuildContext context){
    return ClipPath(

      clipper: DiagonalPathClipperTwo(),
      child: Container(
        color: Colors.white,
        height:MediaQuery.of(context).size.height*0.33,
        child: Row(
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
                  fontSize: 22,
                  fontWeight: FontWeight.w700
              ),
            )
          ],
        ),
      ),
    );

  }

  Widget _textSelectYourRoll(){
    return Text(
        'SELECCIONA TU ROL',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'OneDay'
        )
    );
  }

  Widget _imageTypeUser(BuildContext context, String image, String typeUser){
    return GestureDetector(
      onTap: ()=> _con.goToLoginPage(typeUser),
      child: CircleAvatar(
        backgroundImage: AssetImage(image),
        radius: 50,
        backgroundColor: Colors.grey[900],

      ),
    );
  }

  Widget _textTypeUser(String typeUser){
    return Text(
          typeUser,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16
          ),


    );
  }
}

