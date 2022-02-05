import 'dart:html';

import 'package:chat_app/data/model/room.dart';
import 'package:chat_app/utils/state_control.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class MainController extends StateControl with WidgetsBindingObserver{

  late final BuildContext context;

  late Room room;

  // FirebaseMessaging _firebaseMessaging;
  //
  // HomeController({required context}) {
  //   this.init();
  // }
  //
  // void requestPushNotificationPermission() {
  //   if (Platform.isIOS) {
  //     _firebaseMessaging.requestNotificationPermissions(
  //       IosNotificationSettings(
  //         alert: true,
  //         badge: true,
  //         provisional: false,
  //       ),
  //     );
  //   }
  // }
}