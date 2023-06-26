import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/driver.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/client_provider.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:mi_flutter/src/providers/push_notification_provider.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import '../../utils/my_progress_dialog.dart';

class LoginController{
  BuildContext context;

  GlobalKey<ScaffoldState> key =new GlobalKey<ScaffoldState>();

  TextEditingController emailController= new TextEditingController();
  TextEditingController passwordController= new TextEditingController();
  PushNotificationProvider _pushNotificationProvider =new PushNotificationProvider();

  AuthProvider _authProvider;
  ProgressDialog _progressDialog;
  DriverProvider _driverProvider;
  ClientProvider _clientProvider;

  SharedPref _sharedPref;
  SharedPref _sharedPrefdb;
  String _typeUser;


  Future init(BuildContext context) async{
    this.context=context;
    _authProvider= new AuthProvider();
    _driverProvider= new DriverProvider();
    _clientProvider = new ClientProvider();
    _progressDialog= MyProgressDialog.createProggressDialog(context,'Espere un momento...');
    _sharedPref=new SharedPref();
    _sharedPrefdb=new SharedPref();
    _typeUser=await _sharedPref.read('typeUser');
    print('======Tipo de Usuario======');
    print(_typeUser);
    Client client =Client.fromJson(await _sharedPrefdb.readDB('userDB')??{});
    print('Usuario:=========================> ${client.toJson()}');

    if(client?.session_token!=null){
      print('Esto sirve para asber si el usuario cerro sesion, en este caso NO');
      _pushNotificationProvider.saveTokenDB(client);
    }

  }


  void loginDB() async{
    String email=emailController.text.trim();
    String password=passwordController.text.trim();
    ResponseApi responseApi=await _clientProvider.loginDB(email, password);
    print(responseApi.message);
    print('=====Mensaje de control de la base de datos=====');

    if(responseApi.success){
      print('response api exitoso');

      //Client client=Client.fromJson(responseApi.data);
      Client client=Client.fromJson(responseApi.data);
      _sharedPrefdb.saveDB('userDB', client.toJson());
      Client p= Client.fromJson(await _sharedPrefdb.readDB('userDB'));
      _pushNotificationProvider.saveTokenDB(p);
      print('Aver si si ${p.id}');
      print('Aver si si ${p.username}');
      if(client.roles.length<2){
        print('El Usuario es cliente');
        Navigator.pushNamed(context,'client/map',arguments: client);
      }
      if(client.roles.length>1){
        print('El Usuario es conductor');
        Navigator.pushNamed(context,'driver/map',arguments: client);
      }
      /*if(client.roles.length>1){
        print('El Usuario tiene mas de dos roles osea es un conductor');
        Navigator.pushNamed(context,'roles',arguments: client);
      }
      else{print('solo tiene un rol cliente');
      }*/
    }else
      {print(responseApi.message);
      }
  }


  void login() async{
    String email=emailController.text.trim();
    String password=passwordController.text.trim();


    print('Email:  $email');
    print('Password:  $password');
    if(email.isEmpty&&password.isEmpty){
      print('(╯°□°）╯︵ ┻━┻ |► Error debe ingresar todos los datos');
      utils.Snackbar.showSnackbar(context, key,'(╯°□°）╯︵ ┻━┻ |► Error debe ingresar todos los datos');
    } else {
      _progressDialog.show();
      loginDB();

      try {
        //bool islogin = await _authProvider.login(a, b);

        bool islogin = await _authProvider.login(email, password);
        _progressDialog.hide();
        if (islogin) {
          print('El usuario esta logueado');


          if (_typeUser == 'client') {
            Client client = await _clientProvider.getById(_authProvider
                .getUser()
                .uid);

            print('CLIENT: $client');
            if (client != null) {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'client/map', (route) => false);
              /*Navigator.pushNamedAndRemoveUntil(
                  context, 'roles', (route) => false);*/
            } else {
              utils.Snackbar.showSnackbar(
                  context, key, 'El usuario no es valido');
              await _authProvider.singOut();
            }
          } else if (_typeUser == 'driver') {
            Driver driver = await _driverProvider.getById(_authProvider
                .getUser()
                .uid);
            print('DRIVER: $driver');
            if (driver != null) {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'driver/map', (route) => false);
            }
            else {
              utils.Snackbar.showSnackbar(
                  context, key, 'El usuario no es valido');
              await _authProvider.singOut();
            }
          }
        }
        else {
          utils.Snackbar.showSnackbar(
              context, key, 'El usuario no se pudo autenticar');
          print('El usuario no se pudo autenticar');
        }
      } catch (error) {
        _progressDialog.hide();
        print('Error: $error');
        utils.Snackbar.showSnackbar(context, key, 'Error : $error');
      }
    }




  }



  void goToRegisterPage(){
    if(_typeUser=='client'){
      Navigator.pushNamed(context, 'client/register');
    }else {
      Navigator.pushNamed(context, 'driver/register');
    }

  }



}