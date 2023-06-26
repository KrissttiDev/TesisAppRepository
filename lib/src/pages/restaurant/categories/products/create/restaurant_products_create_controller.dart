import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_flutter/src/models/category.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/providers/categories_provider.dart';
import 'package:mi_flutter/src/providers/products_provider.dart';
import 'package:mi_flutter/src/utils/my_progress_dialog.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';


import '../../../../../models/product.dart';
class RestaurantProductsCreateController{
  BuildContext context;
  Function refresh;


  Client clientDB;
  SharedPref _sharedPrefDB;
  List<Category> categories=[];
  ProgressDialog _progressDialog;

  ImagePicker imagePicker;
  File imageFile1;
  File imageFile2;
  File imageFile3;
  File imageFile4;
  File imageFile5;
  String idCategory; //alñmacena el id de la categoria seleccionada
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();


  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  MoneyMaskedTextController priceController= new MoneyMaskedTextController();

  CategoriesProvider _categoriesProvider=new CategoriesProvider();
  ProductsProvider _productsProvider= new ProductsProvider();







  Future init(BuildContext context, Function  refresh) async{
    this.context=context;
    this.refresh=refresh;
    _sharedPrefDB=new SharedPref();
    clientDB=new Client();
    
    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));
    _categoriesProvider.init(context,clientDB);
    _productsProvider.init(context, clientDB);
    _progressDialog= MyProgressDialog.createProggressDialog(context,'Espere un momento...');

    getCategories();
  }

  void getCategories() async{
    categories=await _categoriesProvider.getAll();
    refresh();

  }

  void createProduct()async{
    String name=nameController.text;
    String description=descriptionController.text;
    double price=priceController.numberValue;
    if (name.isEmpty || description.isEmpty|| price==0) {

      utils.Snackbar.showSnackbar (context,key,'Debe ingresar todos los campos');
      return;
    }
    if(imageFile1==null||imageFile2==null||imageFile3==null){
      utils.Snackbar.showSnackbar (context,key,'Debe ingresar al menos tres imagenes');
      return;
    }

    if(idCategory==null){
      utils.Snackbar.showSnackbar (context,key,'Debe seleccionar la categoria del producto');
      return;

    }

    Product product= new Product(
      name:name,
      description: description,
      price: price,
      id_Category: int.parse(idCategory)
    );
    List<File> images = [];
    images.add(imageFile1);
    images.add(imageFile2);
    images.add(imageFile3);
    images.add(imageFile4);
    images.add(imageFile5);


    //_progressDialog.show();

    Stream stream = await _productsProvider.create(product, images);
    stream.listen((res) {
      //
      // _progressDialog.hide();
      ResponseApi responseApi=ResponseApi.fromJson(json.decode(res));
      utils.Snackbar.showSnackbar(context, key,responseApi.message);
      if(responseApi.success){
        resetValues();
      }

    });
    print('Formulario producto ${product.toJson()}');
   

}


void resetValues(){
    nameController.text='';
    descriptionController.text='';
    priceController.text='0.0';
    imageFile1=null;
    imageFile2=null;
    imageFile3=null;
    imageFile4=null;
    imageFile5=null;
    idCategory=null;
    refresh();


}


  Future getImageFromGalery(ImageSource imageSource,int numberFile)async{
    final XFile pickedFile= await ImagePicker().pickImage(source: imageSource);

    if(pickedFile!=null){
      if(numberFile==1){
        imageFile1=File(pickedFile.path);
      } else if(numberFile==2){
        imageFile2=File(pickedFile.path);
      }else if(numberFile==3){
        imageFile3=File(pickedFile.path);
      }else if(numberFile==4){
        imageFile4=File(pickedFile.path);
      }else if(numberFile==5){
        imageFile5=File(pickedFile.path);
      }

    }else {
      print('No se selecciono una imagen');
    }
    Navigator.pop(context);
    refresh();

  }

  void showAlertDialog(int numberFile) {
    Widget galleryButton= TextButton(
      onPressed: (){
        getImageFromGalery(ImageSource.gallery,numberFile);
      },
      child: Text('GALERIA'),
    );
    Widget cameraButton= TextButton(
      onPressed: (){
        getImageFromGalery(ImageSource.camera, numberFile);
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

}

