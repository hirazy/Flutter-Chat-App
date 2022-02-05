import 'package:chat_app/constants/constant.dart';
import 'package:chat_app/screen/shuffle/component/ic_avatar.dart';
import 'package:chat_app/screen/signin/component/dialog_loading.dart';
import 'package:chat_app/services/service_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  @override
  ProfileState createState() {
    return ProfileState();
  }
}

class ProfileState extends State<StatefulWidget> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  TextEditingController _controllerCurPassword = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  TextEditingController _controllerConfirmPassword = TextEditingController();

  ServiceManager serviceManager = new ServiceManager();

  bool _toggleCur = true;
  bool _toggleNew = true;
  bool _toggleConfirm = true;

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;

    return SafeArea(
        child: Scaffold(
            extendBodyBehindAppBar: false,
            appBar: AppBar(
              leading: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      InkWell(
                        child: const Icon(Icons.arrow_back, size: 24),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )),
              title: Text('Profile'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  icAvatar(URL_ICON, 100.0, 100.0, () {}),
                  const SizedBox(
                    height: 15.0,
                  ),
                  const Text(
                    'Hirazy',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Row(
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter some text';
                              }
                              if (value.length < 6) {
                                return 'Must be more than or equal 6 charater';
                              }
                            },
                            obscureText: _toggleCur,
                            controller: _controllerCurPassword,
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

                        ]),
                    margin: const EdgeInsets.only(left: 10, right: 10),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  // Container(
                  //   child: Row(
                  //     children: [
                  //       TextFormField(
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return 'Please enter some text';
                  //           }
                  //           if (value.length < 6) {
                  //             return 'Must be more than or equal 6 charater';
                  //           }
                  //         },
                  //         obscureText: _toggleNew,
                  //         controller: _controllerPassword,
                  //         textAlign: TextAlign.left,
                  //         decoration: const InputDecoration(
                  //           labelText: "Password",
                  //           labelStyle: TextStyle(
                  //             color: Colors.grey,
                  //           ),
                  //           border: OutlineInputBorder(),
                  //           focusedBorder: OutlineInputBorder(),
                  //         ),
                  //       ),
                  //       FlatButton(
                  //           onPressed: _changeToggleNew,
                  //           child: Text(_toggleNew ? "Show" : "Hide"))
                  //     ],
                  //   ),
                  //   margin: const EdgeInsets.only(left: 10, right: 10),
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // Container(
                  //   child: Row(
                  //     children: [
                  //       TextFormField(
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return 'Please enter some text';
                  //           }
                  //           if (value.length < 6) {
                  //             return 'Must be more than or equal 6 charater';
                  //           }
                  //         },
                  //         obscureText: _toggleConfirm,
                  //         controller: _controllerConfirmPassword,
                  //         textAlign: TextAlign.left,
                  //         decoration: const InputDecoration(
                  //           labelText: "Confirm Password",
                  //           labelStyle: TextStyle(
                  //             color: Colors.grey,
                  //           ),
                  //           border: OutlineInputBorder(),
                  //           focusedBorder: OutlineInputBorder(),
                  //         ),
                  //       ),
                  //       FlatButton(
                  //           onPressed: _changeToggleConfirm,
                  //           child: Text(_toggleConfirm ? "Show" : "Hide"))
                  //     ],
                  //   ),
                  //   margin: const EdgeInsets.only(left: 10, right: 10),
                  // ),
                  // MaterialButton(
                  //   onPressed: () {
                  //     if (_controllerPassword.text ==
                  //         _controllerConfirmPassword.text) {
                  //       Dialogs.showLoadingDialog(context, _keyLoader);
                  //
                  //       serviceManager.updatePassword(
                  //           user!.email!,
                  //           _controllerCurPassword.text,
                  //           _controllerPassword.text, (data) {
                  //         Navigator.of(context, rootNavigator: true).pop();
                  //
                  //         _controllerPassword.text = '';
                  //         _controllerCurPassword.text = '';
                  //         _controllerConfirmPassword.text = '';
                  //
                  //         var response = data as http.StreamedResponse;
                  //
                  //         if (response.statusCode == 200) {
                  //           Fluttertoast.showToast(
                  //               msg: 'Updated Password Successfully!',
                  //               backgroundColor: Colors.green,
                  //               textColor: Colors.white);
                  //         } else {
                  //           Fluttertoast.showToast(
                  //               msg: 'Updated Password Failed!',
                  //               backgroundColor: Colors.red,
                  //               textColor: Colors.white);
                  //         }
                  //       });
                  //     } else {
                  //       Fluttertoast.showToast(
                  //         msg: "Password is not equal!",
                  //         toastLength: Toast.LENGTH_SHORT,
                  //         backgroundColor: Colors.red,
                  //         textColor: Colors.white,
                  //         gravity: ToastGravity.BOTTOM,
                  //       );
                  //     }
                  //   },
                  //   child: const Text(
                  //     'Update Password',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  //   color: Colors.blue,
                  // )
                ],
              ),
            )));
  }

  void _changeToggleCur() {
    setState(() {
      _toggleCur = !_toggleCur;
    });
  }

  void _changeToggleNew() {
    setState(() {
      _toggleNew = !_toggleNew;
    });
  }

  void _changeToggleConfirm() {
    setState(() {
      _toggleConfirm = !_toggleConfirm;
    });
  }
}
