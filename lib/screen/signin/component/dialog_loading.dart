import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Column(children: const [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }

  static Future<void> showDialogSignIn(
      String email, BuildContext context, GlobalKey key, callBack) async {
    TextEditingController _controllerText = TextEditingController();

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        Container(
                          child: TextField(
                            enabled: false,
                            showCursor: true,
                            readOnly: true,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              labelText: email,
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                            ),
                          ),
                          margin: const EdgeInsets.only(left: 10, right: 10),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TextField(
                            obscureText: true,
                            controller: _controllerText,
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                            ),
                          ),
                          margin: const EdgeInsets.only(left: 10, right: 10),
                        ),
                        MaterialButton(
                          onPressed: () {
                            callBack(_controllerText.text);
                          },
                          child: Container(
                            child: const Text(
                              'Sigin In',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          color: Colors.blue,
                        )
                      ]),
                    )
                  ]));
        });
  }

  static Future<void> showDialogSignUp(
      String email, BuildContext context, GlobalKey key, callBack) async {
    TextEditingController _controllerPassword = TextEditingController();
    TextEditingController _controllerConfirmPassword = TextEditingController();

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        Container(
                          child: TextField(
                            enabled: false,
                            showCursor: true,
                            readOnly: true,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              labelText: email,
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                            ),
                          ),
                          margin: const EdgeInsets.only(left: 10, right: 10),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter some text';
                              }
                              if (value.length < 6) {
                                return 'Must be more than or equal 6 charater';
                              }
                            },
                            obscureText: true,
                            controller: _controllerPassword,
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                            ),
                          ),
                          margin: const EdgeInsets.only(left: 10, right: 10),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter some text';
                              }
                              if (value.length < 6) {
                                return 'Must be more than or equal 6 charater';
                              }
                            },
                            obscureText: true,
                            controller: _controllerConfirmPassword,
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              labelText: "Confirm Password",
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                            ),
                          ),
                          margin: const EdgeInsets.only(left: 10, right: 10),
                        ),
                        MaterialButton(
                          onPressed: () {
                            if (_controllerPassword.text.length >= 6 &&
                                _controllerPassword.text ==
                                    _controllerConfirmPassword.text) {
                              callBack(_controllerConfirmPassword.text);
                            } else {
                              if (_controllerPassword.text !=
                                  _controllerConfirmPassword.text) {
                                Fluttertoast.showToast(
                                  msg: "Password is not equal!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg:
                                      "Password must contain more than or equal 6 characters!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              }
                            }
                          },
                          child: Container(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          color: Colors.blue,
                        )
                      ]),
                    )
                  ]));
        });
  }
}
