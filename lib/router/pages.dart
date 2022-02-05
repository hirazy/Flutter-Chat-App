import 'package:chat_app/router/routes.dart';
import 'package:chat_app/screen/main/ui/main.dart';
import 'package:chat_app/screen/splash/ui/splash.dart';
import 'package:flutter/cupertino.dart';

class CommonPage {
  static List pages = [
    RouteModel(
      CommonRoutes.INIT,
      Splash(),
    ),
    RouteModel(
      CommonRoutes.MAIN,
      MyHomePage(title: '',),
    ),
  ];
}

class RouteModel {
  String name;
  Widget page;

  RouteModel(this.name, this.page);
}
