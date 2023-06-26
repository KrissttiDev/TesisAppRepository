
import 'dart:convert';
import 'dart:io';


import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/response_api.dart';

import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/client_provider.dart';
import 'package:mi_flutter/src/providers/storage_provider.dart';
import 'package:mi_flutter/src/utils/my_progress_dialog.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';


class ClientEditController{
  BuildContext context;
  GlobalKey<ScaffoldState> key =new GlobalKey<ScaffoldState>();
  Function refresh;

  TextEditingController usernameController= new TextEditingController();
  TextEditingController phoneController= new TextEditingController();
  TextEditingController lastnameController= new TextEditingController();


  AuthProvider _authProvider;
  ClientProvider _clientProvider;
  

  ProgressDialog _progressDialog;

  StorageProvider _storageProvider;
  PickedFile PFile;
  XFile pickedFile;

  //final ImagePicker pickedFile=ImagePicker();

  File imageFile;

  Client client;
  Client clientDB;
  SharedPref _sharedPrefdb = new SharedPref();
  String prueba;



  Future init(BuildContext context, Function refresh) async{
    this.context=context;
    this.refresh=refresh;

    _authProvider= new AuthProvider();
    _clientProvider = new ClientProvider();
    _storageProvider= new StorageProvider();

    _progressDialog= MyProgressDialog.createProggressDialog(context,'Espere un momento...');
    getUserInfo();
    clientDB = Client.fromJson(await _sharedPrefdb.readDB('userDB'));




    print('El susuario es :${clientDB.roles}');
    print('El susuario es :${clientDB.username}');
    print('El susuario es :${clientDB.lastname}');

  }



  void getUserInfo()async{
    client = await _clientProvider.getById(_authProvider.getUser().uid);
    usernameController.text=client.username;
    lastnameController.text=client.lastname;
    phoneController.text=client.phone;
    refresh();


  }


  void showAlertDialog() {
    Widget galleryButton= TextButton(
      onPressed: (){
        getImageFromGalery(ImageSource.gallery);
      },
      child: Text('GALERIA'),
    );
    Widget cameraButton= TextButton(
      onPressed: (){
        getImageFromGalery(ImageSource.camera);
      },
      child: Text('CAMERA'),
    );
    AlertDialog alertDialog=AlertDialog(
      title: Text('Selecciona tu imagen'),
      actions: [
        galleryButton,
        cameraButton
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context){
          return alertDialog;
        }
    );
  }

  void updateBdd()async{
    print('===================================== aqui va el id');
    print(clientDB.id);
    print(clientDB.username);
    print(clientDB.lastname);
    print(clientDB.phone);
    print(clientDB.session_token);
    print('=====================================');






    String username=usernameController.text;
    String lastname=lastnameController.text;
    String phone=phoneController.text;
    if(username.isEmpty ){
      print('Debe ingresar todos los campos');
      utils.Snackbar.showSnackbar(context, key, 'Debe llenar todos los campos');

      return;
    }
    _progressDialog.show();

    Client client=new Client(

      id:clientDB.id,
      username:username,
      lastname:lastname,
      phone:phone,
      image: clientDB.image,
      session_token: clientDB.session_token

    );

   


    Stream stream = await _clientProvider.updateDB(client,imageFile);
    update();
    print(clientDB.session_token);
    _progressDialog.hide();

    stream.listen((res) async{
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

      if(responseApi.success){

        Client clientUpdate=await _clientProvider.getByIdDB(clientDB.id,clientDB);//obteniendo usuario de la base de datops
        _sharedPrefdb.saveDB('userDB', clientUpdate);
        print('ResponseApi = verdadero pruna : ${clientUpdate.username}');
        Navigator.pushReplacementNamed(context, 'client/map');




      }
      print('RESPUESTA: ${responseApi.toJson()}');
      utils.Snackbar.showSnackbar(context, key, 'Los datos se han actualizaron correctamente');

      //utils.Snackbar.showSnackbar(context, key, 'No se pudieron Actualizar los datos');


    });



  }



  void update() async{
    String username=usernameController.text;
    String lastname=lastnameController.text;
    String phone=phoneController.text;

    /*if(username.isEmpty ){
      print('Debe ingresar todos los campos');
      utils.Snackbar.showSnackbar(context, key, 'Debe llenar todos los campos');

      return;
    }


    _progressDialog.show();*/


    if(pickedFile==null){
      Map<String,dynamic> data= {
        //'image':client?.image??null,
        'username':username,
        'lastname':lastname,
        'phone':phone,
      };
      await _clientProvider.update(data, _authProvider.getUser().uid);


      _progressDialog.hide();
    }else{
      TaskSnapshot snapshot=await _storageProvider.uploadFile(imageFile);
      String imageUrl=await snapshot.ref.getDownloadURL();
      Map<String,dynamic> data= {
        'image':imageUrl,
        'username':username,
        'lastname':lastname,
        'phone':phone,
      };
      await _clientProvider.update(data, _authProvider.getUser().uid);
      
    }

    /*_progressDialog.hide();
    utils.Snackbar.showSnackbar(context, key, 'Los datos se actualizaron');*/



  }

  Future getImageFromGalery(ImageSource imageSource)async{
    final XFile pickedFile= await ImagePicker().pickImage(source: imageSource);

    if(pickedFile!=null){
      imageFile=File(pickedFile.path);


    }else {
      print('No se selecciono una imagen');
    }

    Navigator.pop(context);
    refresh();

  }


  }





