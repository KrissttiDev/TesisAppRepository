import 'package:flutter/cupertino.dart';
import 'package:mi_flutter/src/providers/client_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/client.dart';

class SharedPref{

  void save (String key, String value) async {
    final prefs= await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  Future<dynamic> read(String key) async{
    final prefs= await SharedPreferences.getInstance();
    if(prefs.getString(key)==null) return null;

    return json.decode(prefs.getString(key));

  }


  //nombre --- true -false
  //si existe un valos con una key establecida
  Future<bool> contains(String key) async{
    final prefs= await SharedPreferences.getInstance();
    return prefs.containsKey(key);

  }

  remove (String key) async{
    final prefs= await SharedPreferences.getInstance();
    return prefs.remove(key);
  }


  //====================================base de datos================================
  //preference para la base de dados
  void saveDB (String keyDB, value) async {
    final prefs= await SharedPreferences.getInstance();
    prefs.setString(keyDB, json.encode(value));
  }

  Future<dynamic> readDB(String keyDB) async{
    final prefs= await SharedPreferences.getInstance();
    if(prefs.getString(keyDB)==null) return null;

    return json.decode(prefs.getString(keyDB));

  }

  Future<bool> containsDB(String keyDB) async{
    final prefs= await SharedPreferences.getInstance();
    return prefs.containsKey(keyDB);

  }

  Future<bool>removeDB (String keyDB) async{

    final prefs= await SharedPreferences.getInstance();
    return prefs.remove(keyDB);
  }


  void logoutBD(BuildContext context,Client clienDB) async{
    ClientProvider clientProvider= new ClientProvider();
    //await clientProvider.logoutDB(clienDB.id);
    //await removeDB('userDB');

    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);

  }




}





