import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

Future<void> backgroundHandler(RemoteMessage message) async {
  print('fcm_services/backgroundHandler: msg: ${message.notification!.title}');
}

class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  void initFCM(BuildContext context) {}

  void getToken() {
    _fcm.getToken().then((token) => {});
  }

  void onBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  }

  void onMessageOpenedApp(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data['route'];
      
      Navigator.of(context).pushNamed(routeFromMessage);
    });
  }

  Future<Map<String, dynamic>> sendMessage({targetToken, title, body, route}) async {
    var serverToken = '';

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': <String, dynamic>{
            'route': route,
          },
          'to': targetToken,
        },
      ),
    );
    return {};
  }
}
