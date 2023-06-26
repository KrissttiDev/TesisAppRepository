import 'dart:io';


import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_flutter/src/models/driver.dart';

import 'package:mi_flutter/src/providers/auth_provider.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:mi_flutter/src/providers/storage_provider.dart';
import 'package:mi_flutter/src/utils/my_progress_dialog.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';


class DriverEditController{
  BuildContext context;
  GlobalKey<ScaffoldState> key =new GlobalKey<ScaffoldState>();

  TextEditingController usernameController= new TextEditingController();


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

  StorageProvider _storageProvider;


  final ImagePicker pickedFile=ImagePicker();

  File imageFile;

  Driver driver;
  Function refresh;

  Future init(BuildContext context, Function refresh){
    this.context=context;
    this.refresh=refresh;

    _authProvider= new AuthProvider();
    _driverProvider = new DriverProvider();
    _storageProvider=new StorageProvider();
    _progressDialog= MyProgressDialog.createProggressDialog(context,'Espere un momento...');
    getUserInfo();
  }




  void update() async {
    String username = usernameController.text;

    String pin1 = pin1Controller.text.trim();
    String pin2 = pin2Controller.text.trim();
    String pin3 = pin3Controller.text.trim();
    String pin4 = pin4Controller.text.trim();
    String pin5 = pin5Controller.text.trim();
    String pin6 = pin6Controller.text.trim();
    String pin7 = pin7Controller.text.trim();

    String plate = '$pin1$pin2$pin3-$pin4$pin5$pin6$pin7';


    if (username.isEmpty) {
      print('debes ingresar todos los campos');
      utils.Snackbar.showSnackbar(context, key, 'Debes ingresar todos los campos');
      return;
    }
    _progressDialog.show();


    if (pickedFile == null) {
      Map<String, dynamic> data = {
        //'image': driver?.image ?? null,
        'username': username,
        'plate': plate,
      };

      await _driverProvider.update(data, _authProvider.getUser().uid);
      _progressDialog.hide();
    }
    else {


      TaskSnapshot snapshot = await _storageProvider.uploadFile(imageFile);
      String imageUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> data = {
        'image': imageUrl,
        'username': username,
        'plate': plate,
      };

      await _driverProvider.update(data, _authProvider.getUser().uid);
    }

    _progressDialog.hide();

    utils.Snackbar.showSnackbar(context, key, 'Los datos se actualizaron');

  }





  void updateTo() async{

    String username=usernameController.text;

    String pin1=pin1Controller.text.trim();
    String pin2=pin2Controller.text.trim();
    String pin3=pin3Controller.text.trim();
    String pin4=pin4Controller.text.trim();
    String pin5=pin5Controller.text.trim();
    String pin6=pin6Controller.text.trim();
    String pin7=pin7Controller.text.trim();

    String plate = '$pin1$pin2$pin3-$pin4$pin5$pin6$pin7';



    if(username.isEmpty ){
      print('Debe ingresar todos los campos');
      utils.Snackbar.showSnackbar(context, key, 'Debe llenar todos los campos');

      return;
    }

    _progressDialog.show();


    if(pickedFile==null){

      Map<String,dynamic> data= {
        'image':driver?.image??null,
        'username':username,
        'plate':plate
      };
      await _driverProvider.update(data, _authProvider.getUser().uid);
      _progressDialog.hide();
    }else{

      TaskSnapshot snapshot=await _storageProvider.uploadFile(imageFile);
      String imageUrl=await snapshot.ref.getDownloadURL();
      Map<String,dynamic> data= {
        'image':imageUrl,
        'username':username,
        'plate':plate
      };
      await _driverProvider.update(data, _authProvider.getUser().uid);

    }


    _progressDialog.hide();
    utils.Snackbar.showSnackbar(context, key, 'Los datos se actualizaron');


  }

  void getUserInfo()async{
    driver = await _driverProvider.getById(_authProvider.getUser().uid);
    usernameController.text=driver.username;

    pin1Controller.text=driver.plate[0];
    pin2Controller.text=driver.plate[1];
    pin3Controller.text=driver.plate[2];
    pin4Controller.text=driver.plate[4];
    pin5Controller.text=driver.plate[5];
    pin6Controller.text=driver.plate[6];
    pin7Controller.text=driver.plate[7];


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





  Future getImageFromGalery(ImageSource imageSource)async{
    final XFile pickedFile= await ImagePicker().pickImage(source: imageSource);
    if(pickedFile!=null){

      imageFile=File(pickedFile.path);
      refresh();


    }else {
      print('No se selecciono una imagen');
    }
    Navigator.pop(context);
    refresh();

  }

















}