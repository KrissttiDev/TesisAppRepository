import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/client.dart';

import 'package:mi_flutter/src/models/response_api.dart';

import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/client_provider.dart';
import 'package:mi_flutter/src/utils/my_progress_dialog.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';



class ClientRegisterController{


  BuildContext context;
  GlobalKey<ScaffoldState> key =new GlobalKey<ScaffoldState>();

  TextEditingController usernameController= new TextEditingController();
  TextEditingController emailController= new TextEditingController();

  TextEditingController passwordController= new TextEditingController();
  TextEditingController confirmpasswordController= new TextEditingController();
  TextEditingController phoneController= new TextEditingController();
  TextEditingController lastnameController= new TextEditingController();

  AuthProvider _authProvider;
  ClientProvider _clientProvider;
  ProgressDialog _progressDialog;


  Future init(BuildContext context){
    this.context=context;
    //_user.init(context);
    _authProvider= new AuthProvider();
    _clientProvider = new ClientProvider();
    _progressDialog= MyProgressDialog.createProggressDialog(context,'Espere un momento...');
  }


  void register() async{
    String username=usernameController.text;
    String email=emailController.text.trim();
    String password=passwordController.text.trim();
    String confirmpassword=confirmpasswordController.text.trim();
    String phone=phoneController.text.trim();
    String lastname=lastnameController.text.trim();

    print('Email:  $email');
    print('Password:  $password');
    if(username.isEmpty || email.isEmpty || password.isEmpty || confirmpassword.isEmpty||phone.isEmpty||lastname.isEmpty){
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
        Client client = new Client(
          id: _authProvider.getUser().uid,
          email: _authProvider.getUser().email,
          username: username,
          lastname: lastname,
          password: password,
          phone: phone,
        );

        await _clientProvider.create(client);
        //base de datos
        ResponseApi responseApi = await _clientProvider.createDB(client); //base de datos
        print('RESPUESTA: ${responseApi.toJson()}');
        if(responseApi.success){print('Usuario registrado exitosamente en la base de datos cliente');}

        _progressDialog.hide();
        Navigator.pushNamedAndRemoveUntil(context, 'client/map',(route)=>false);
        print('El usuario se registro correctamente');

        utils.Snackbar.showSnackbar(context, key, 'El usuario se registro correctamente');

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