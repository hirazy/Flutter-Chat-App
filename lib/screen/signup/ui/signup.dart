import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  SignUpState createState() {
    return SignUpState();
  }
}

class SignUpState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Scaffold(
          backgroundColor: Colors.blueAccent,
          body: Text(
              "Show", style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ));
  }
}