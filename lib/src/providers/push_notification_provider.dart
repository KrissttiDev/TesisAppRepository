
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/providers/client_provider.dart';
import 'package:mi_flutter/src/providers/driver_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mi_flutter/src/utils/share_pref.dart';


class PushNotificationProvider{
  AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();
  ClientProvider clientProvider=new ClientProvider();




  StreamController _streamController= StreamController<Map<String,dynamic>>.broadcast();

  Stream<Map<String,dynamic>> get message=>_streamController.stream;


  //=================================Notifications BD==================================================

  void initNotificationsBD() async{
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);


    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

  }


  void onMessageListenerDB() async {

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      print('NUEVA NOTIFICACION EN PRIMER PLANO');

      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');

    });

  }


  void saveTokenDB(Client clientDB)async{
    String token= await FirebaseMessaging.instance.getToken();
    print(token);

    clientProvider.updateNotificationTokenDB(clientDB, token);


  }

  Future <void> sendMessageDB(String to, Map<String, dynamic>data, String title, String body)async{
    Uri uri = Uri.https('fcm.googleapis.com', '/fcm/send');
    await http.post(
      uri,
      headers: <String,String>{
        'Content-Type':'application/json',
        'Authorization':'key=AAAAUTO9QOE:APA91bGWsNUTgertbYpm5xdyNSatG8ZHsj97YsuvE6dzLxQFj5-7vkSmjaWmsbh3vA9KM7xOUHSmWmXI1feZq5736_DPKl86wnOM3B2LJIlQWIImyPNN604k0AsK_PC4cQMH0qPMe4IR',
      },
        body: jsonEncode(
        <String,dynamic>{
        'notification':<String,dynamic>{
        'body':body,
        'title':title
        },
        'priority':'high',
        'ttl':'4500s',
        'data':data,
        'to':to

        })

    );
  }

  Future <void> sendMessageMultipleDB(List<String> toList, Map<String, dynamic>data, String title, String body)async{
    Uri uri = Uri.https('fcm.googleapis.com', '/fcm/send');
    await http.post(
        uri,
        headers: <String,String>{
          'Content-Type':'application/json',
          'Authorization':'key=AAAAUTO9QOE:APA91bGWsNUTgertbYpm5xdyNSatG8ZHsj97YsuvE6dzLxQFj5-7vkSmjaWmsbh3vA9KM7xOUHSmWmXI1feZq5736_DPKl86wnOM3B2LJIlQWIImyPNN604k0AsK_PC4cQMH0qPMe4IR',
        },
        body: jsonEncode(
            <String,dynamic>{
              'notification':<String,dynamic>{
                'body':body,
                'title':title
              },
              'priority':'high',
              'ttl':'4500s',
              'data':data,
              'registration_ids':toList

            })

    );
  }






  //========================================================================================================

    void initPushNotification() async{


    //ON LAUNCH
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
      if (message != null) {
        Map<String, dynamic> data = message.data;
        SharedPref sharedPref = new SharedPref();
        sharedPref.save('isNotification', 'true');
        _streamController.sink.add(data);
      }
    });


    // ON MESSAGE
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      Map<String, dynamic> data = message.data;

      print('Cuando estamos en primer plano');
      print('OnMessage: $data');
      _streamController.sink.add(data);

    });

    FirebaseMessaging.instance.requestPermission();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );





    //ON RESUME
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Map<String,dynamic> data=message.data;
      print('A new onMessageOpenedApp event has published');
      print('OnResume: $data');
      _streamController.sink.add(data);
    });





  }


  void saveToken(String idUser, String typeUser) async{
    String token = await FirebaseMessaging.instance.getToken();
    Map<String,dynamic> data= {
      'token':token
    };

    if(typeUser =='client'){
      ClientProvider clientProvider =new ClientProvider();

      clientProvider.update(data, idUser);
    }
    else {
      DriverProvider driverProvider =new DriverProvider();

      driverProvider.update(data, idUser);

      }
    }


    Future<void> sendMessage(String to,Map<String,dynamic> data, String title,String body) async{
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String,String> {
            'Content-Type':'application/json',
            'Authorization':'key=AAAAUTO9QOE:APA91bGWsNUTgertbYpm5xdyNSatG8ZHsj97YsuvE6dzLxQFj5-7vkSmjaWmsbh3vA9KM7xOUHSmWmXI1feZq5736_DPKl86wnOM3B2LJIlQWIImyPNN604k0AsK_PC4cQMH0qPMe4IR',
            
        },
        body: jsonEncode(
          <String,dynamic>{
            'notification':<String,dynamic>{
              'body':body,
              'title':title
            },
            'priority':'high',
            'ttl':'4500s',
            'data':data,
            'to':to

          }


        )
      );

    }

  Future<void> sendMessageClient(String to, String title,String body) async{
    await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String,String> {
          'Content-Type':'application/json',
          'Authorization':'key=AAAAUTO9QOE:APA91bGWsNUTgertbYpm5xdyNSatG8ZHsj97YsuvE6dzLxQFj5-7vkSmjaWmsbh3vA9KM7xOUHSmWmXI1feZq5736_DPKl86wnOM3B2LJIlQWIImyPNN604k0AsK_PC4cQMH0qPMe4IR',

        },
        body: jsonEncode(
            <String,dynamic>{
              'notification':<String,dynamic>{
                'body':body,
                'title':title
              },
              'priority':'high',
              'ttl':'4500s',

              'to':to

            }


        )
    );

  }


    void dispose(){
    _streamController?.onCancel;
    }




  }


