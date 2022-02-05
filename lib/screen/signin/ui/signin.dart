import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/data/model/user.dart';
import 'package:chat_app/helper/shared_preferences.dart';
import 'package:chat_app/router/routes.dart';
import 'package:chat_app/screen/signin/component/dialog_loading.dart';
import 'package:chat_app/services/service_manager.dart';
import 'package:chat_app/utils/user_security_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class Signin extends StatefulWidget {
  @override
  State<Signin> createState() {
    return SigninState();
  }
}

class SigninState extends State<Signin> with TickerProviderStateMixin {
  late final AnimationController _controller;

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  String TEXT_SIGNUP = "Sign up with google";
  String SIGN_IN = "sign_in";
  String SIGN_UP = "sign_up";
  String DEFAULT_PASSWORD = "default_123";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/raw/anim_signin.json',
            controller: _controller,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..forward();
              _controller.repeat(reverse: true);
            },
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: () {
                _auth_Google(SIGN_IN);
              },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFF397AF3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(3),
                        child: SvgPicture.asset('assets/img/ic_google.svg',
                            width: 30,
                            height: 30,
                            semanticsLabel: 'A red up arrow'),
                      ),
                      SizedBox(width: 12),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () {
                _auth_Google(SIGN_UP);
              },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFF397AF3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(3),
                        child: SvgPicture.asset('assets/img/ic_google.svg',
                            width: 30,
                            height: 30,
                            semanticsLabel: 'A red up arrow'),
                      ),
                      // <-- Use 'Image.asset(...)' here
                      SizedBox(width: 12),
                      Text(
                        TEXT_SIGNUP,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Sign in Google
  /// Sign in User by email
  /// If email is signed => receive token from server
  /// else => Sign up
  /// Status: 201 Created
  /// @param res:{
  ///  "token": "123",
  ///  "user": {
  ///    "id": "",
  ///    "name": "",
  ///    "picture": "",
  ///    "email": "",
  ///    "createdAt": ""
  ///  }
  /// }
  ///
  /// Status: 401 Unauthorized
  _auth_Google(KEY_AUTH) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        /// User sign in success
        user = userCredential.user;

        /// Post to Server - User
        if (user!.emailVerified! == true) {
          ServiceManager serviceManager = ServiceManager();

          /// Sign in
          if (KEY_AUTH == SIGN_IN) {
            Dialogs.showDialogSignIn(user.email!, context, _keyLoader,
                (password) {
              /// Popup dialog
              Navigator.of(context, rootNavigator: true).pop();

              /// Show Dialog
              Dialogs.showLoadingDialog(context, _keyLoader);

              serviceManager.signin_User(user!.email!, password, (data) async {
                /// Popup dialog
                Navigator.of(context, rootNavigator: true).pop();

                var res = data as http.Response; // As Response

                /// Sign in OK AND RETURN TOKEN
                /// Status Code 201
                if (res.statusCode == 201) {
                  var userResponse = res.body;
                  UserResponse response =
                      UserResponse.fromJson(json.decode(userResponse));

                  await SharedPreferencesHelper.shared
                      .saveMyID(response.user!.id!);

                  /// Change
                  Navigator.pushReplacementNamed(context, CommonRoutes.SHUFFLE);

                  /// Save Token
                  UserSecurityStorage.setToken(response.token!);
                } else {
                  if (res.statusCode == 401) {
                    showToast("Unauthorized Message!", Colors.red);
                  } else {
                    if (res.statusCode >= 500) {
                      showToast("Server is not responding!", Colors.red);
                    } else {
                      showToast("No Internet Connection!", Colors.red);
                    }
                  }
                  await auth.signOut();
                  await googleSignIn.signOut();
                }
              });
            });
          }

          /// Sign up
          else {
            Dialogs.showDialogSignUp(user.email!, context, _keyLoader,
                (password) {
              Navigator.of(context, rootNavigator: true).pop();

              Dialogs.showLoadingDialog(context, _keyLoader);

              serviceManager.signup_User(
                  user!.email!, password, user.displayName, user.photoURL,
                  (data) async {
                Navigator.of(context, rootNavigator: true).pop();

                var res = data as http.Response; // As Response

                /// Sign up OK
                if (res.statusCode == 201) {
                  showToast("Signed Up Successfully!", Colors.green);
                } else {
                  /// Master access only.
                  if (res.statusCode == 401) {
                    showToast("Not permission to access!", Colors.red);
                  }

                  /// Email already registered
                  else if (res.statusCode == 409) {
                    showToast("Email already registered!", Colors.red);
                  } else {
                    if(res.statusCode >= 500){
                      showToast("Server not respond!", Colors.red);
                    }
                    else{

                      showToast("No Internet Connection!", Colors.red);
                    }
                  }

                  await auth.signOut();
                  await googleSignIn.signOut();
                }
              });
            });

            /// Show Dialog
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          showToast("Account exists with different credential!", Colors.red);
        } else if (e.code == 'invalid-credential') {
          showToast("Invalid Credential!", Colors.red);
        }

        await auth.signOut();
        await googleSignIn.signOut();
      } catch (e) {
        // handle the error here
      }
    }
  }

  void showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: color,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
