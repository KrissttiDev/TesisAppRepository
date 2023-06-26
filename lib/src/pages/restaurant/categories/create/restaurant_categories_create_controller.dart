import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/category.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/providers/categories_provider.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:mi_flutter/src/utils/snackbar.dart' as utils;
class RestaurantCategoriesCreateController{
  BuildContext context;
  Function refresh;


  Client clientDB;
  SharedPref _sharedPrefDB;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  CategoriesProvider _categoriesProvider=new CategoriesProvider();







  Future init(BuildContext context, Function  refresh) async{
    this.context=context;
    this.refresh=refresh;

    _sharedPrefDB=new SharedPref();
    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));

    _categoriesProvider.init(context,clientDB);
    refresh();
    print(clientDB.id);
    print(clientDB.username);
  }

  void prueba()async{
    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));
    print(clientDB.id);
    print(clientDB.username);
  }

  void createCategory()async{
    String name=nameController.text;
    String description=descriptionController.text;
    if (name.isEmpty || description.isEmpty) {

      utils.Snackbar.showSnackbar (context,key,'Debe ingresar todos los campos');
      return;
    }

      Category category= new Category(
        name:name,
        description: description
      );


      ResponseApi responseApi=await _categoriesProvider.createDB(category);
    utils.Snackbar.showSnackbar(context, key,'Fue creado exitosamente');
      if(responseApi.success){
        nameController.text='';
        descriptionController.text='';
      }


      print(name);
      print(description);


  }


}