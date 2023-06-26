import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/driver.dart';
import 'package:mi_flutter/src/models/rol.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';

class RolesController{
  BuildContext context;
  Function refresh;

  GlobalKey<ScaffoldState> key =new GlobalKey<ScaffoldState>();
  Client client;
  Client clientDB;
  Driver driver;

  SharedPref _sharedPref;
  SharedPref _sharedPrefDB;
  String _typeUser;
  String user;

  Future init(BuildContext context, Function refresh) async{
    this.context=context;
    this.refresh=refresh;


    _sharedPref=new SharedPref();
    _sharedPrefDB=new SharedPref();
    _typeUser=await _sharedPref.read('typeUser');
    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));
    refresh();
    print('=====ooooooooooooooooo=========');
    print(clientDB.roles);

  }
  void goToPage(String route) {
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false, arguments: clientDB);
  }


}