

import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/driver.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:mi_flutter/src/utils/my_progress_dialog.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';

import '../../../models/driver.dart';


class DriverRegisterController{
  BuildContext context;
  GlobalKey<ScaffoldState> key =new GlobalKey<ScaffoldState>();

  TextEditingController usernameController= new TextEditingController();
  TextEditingController emailController= new TextEditingController();
  TextEditingController passwordController= new TextEditingController();
  TextEditingController confirmpasswordController= new TextEditingController();

  TextEditingController phoneController= new TextEditingController();
  TextEditingController lastnameController= new TextEditingController();

  TextEditingController pin1Controller = new TextEditingController();
  TextEditingController pin2Controller = new TextEditingController();
  TextEditingController pin3Controller= new TextEditingController();
  TextEditingController pin4Controller = new TextEditingController();
  TextEditingController pin5Controller = new TextEditingController();
  TextEditingController pin6Controller = new TextEditingController();
  TextEditingController pin7Controller = new TextEditingController();



  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  ProgressDialog _progressDialog;

  Future init(BuildContext context){
    this.context=context;
    _authProvider= new AuthProvider();
    _driverProvider = new DriverProvider();
    _progressDialog= MyProgressDialog.createProggressDialog(context,'Espere un momento...');
  }


  void register() async{
    String username=usernameController.text;
    String email=emailController.text.trim();
    String password=passwordController.text.trim();
    String confirmpassword=confirmpasswordController.text.trim();
    String phone=phoneController.text.trim();
    String lastname=lastnameController.text.trim();
    bool activated=false;

    String pin1=pin1Controller.text.trim();
    String pin2=pin2Controller.text.trim();
    String pin3=pin3Controller.text.trim();
    String pin4=pin4Controller.text.trim();
    String pin5=pin5Controller.text.trim();
    String pin6=pin6Controller.text.trim();
    String pin7=pin7Controller.text.trim();

    String plate = '$pin1$pin2$pin3-$pin4$pin5$pin6$pin7';


    print('Email:  $email');
    print('Password:  $password');
    if(username.isEmpty && email.isEmpty && password.isEmpty && confirmpassword.isEmpty){
      print('Debe ingresar todos los campos');
      utils.Snackbar.showSnackbar(context, key, 'Debe llenar todos los campos');

      return;
    }

    if(confirmpassword != password){
      print('Las contraseñas no coinciden');
      utils.Snackbar.showSnackbar(context, key, 'Las contraseñas no coinciden');

      return;
    }
    if(password.length<6){
      print('El password debe tener al menos 6 caracteres');
      utils.Snackbar.showSnackbar(context, key, 'El password debe tener al menos 6 caracteres');

      return;
    }
    _progressDialog.show();

    try {
      bool isRegister=await _authProvider.register(email, password);
      if(isRegister){
        Driver driver = new Driver(
          id: _authProvider.getUser().uid,
          email: _authProvider.getUser().email,
          username: username,
          lastname: lastname,
          password: password,
          phone: phone,
          plate:plate,
          activated:activated

        );
        await _driverProvider.create(driver);
        ResponseApi responseApi = await _driverProvider.createDB(driver); //base de datos
        print('RESPUESTA: ${responseApi.toJson()}');
        if(responseApi.success){print('Usuario registrado exitosamente en la base de datos cliente');}

        _progressDialog.hide();
        Navigator.pushNamedAndRemoveUntil(context, 'driver/map',(route)=>false);
        print('El conductorse registro correctamente');
        utils.Snackbar.showSnackbar(context, key, 'El conductor se registro correctamente');




      }
        else{
          _progressDialog.hide();
        print('No se pudo registar');
        utils.Snackbar.showSnackbar(context, key, 'No se pudo registar');



      }



    }catch(error){
      _progressDialog.hide();
      utils.Snackbar.showSnackbar(context, key, 'Error: $error');
      print('Error: $error');
    }




  }





}