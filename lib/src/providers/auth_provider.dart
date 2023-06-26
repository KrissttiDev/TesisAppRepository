import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthProvider {

  FirebaseAuth _firebaseAuth;

  AuthProvider(){
    _firebaseAuth = FirebaseAuth.instance;
  }

  User getUser(){
    return _firebaseAuth.currentUser;
  }

  bool isSignedIn(){
    final currentUser= _firebaseAuth.currentUser;
    if(currentUser==null){
      return false;
    }else {
      return true;
    }
  }

  void checkUserIsLogged(BuildContext context, String typeUser){
    FirebaseAuth.instance.authStateChanges().listen((User user) { 
      
      if(user!=null&& typeUser!=null){

        if(typeUser=='client'){

          Navigator.pushNamedAndRemoveUntil(context, 'client/map',(route)=>false);

        } else{
          Navigator.pushNamedAndRemoveUntil(context, 'driver/map',(route)=>false);

        }

        print('El usuario esta loggeado----');


      }else {
        print('El usuario NO esta loggeado');

      }
    });
  }



  Future<bool> login(String email, String password) async {
    String errorMessage;

    try {
      
       await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

    }catch(error){
      print(error);
      //correo invalido
      //password invalido
      //no hay conexion a internet
      errorMessage=error.code;
    }
    if(errorMessage !=null){
      return Future.error(errorMessage);
    }
    return true;
  }




  Future<bool> register(String email, String password) async {
    String errorMessage;

    try {

      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    }catch(error){
      print(error);
      //correo invalido
      //password invalido
      //no hay conexion a internet
      errorMessage=error.code;
    }
    if(errorMessage !=null){
      return Future.error(errorMessage);
    }
    return true;
  }


  Future<void> singOut() async{

    return Future.wait([_firebaseAuth.signOut()]);


  }


}