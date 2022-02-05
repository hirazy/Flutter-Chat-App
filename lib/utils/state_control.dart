import 'dart:async';

import 'package:chat_app/utils/state_abstract_control.dart';

class StateControl implements StateAbstractControl{

  final StreamController streamController;

  StateControl() : streamController = StreamController();


  @override
  void dispose() {
    streamController.close();
  }

  @override
  void init() {
    // TODO: implement init
  }

  @override
  void notifyListeners() {
    streamController.add('change');
  }

}