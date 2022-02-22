import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/bloc/shuffle/shuffle_bloc.dart';
import 'package:chat_app/bloc/shuffle/shuffle_state.dart';
import 'package:chat_app/constants/constant.dart';
import 'package:chat_app/data/db/database_helper.dart';
import 'package:chat_app/data/model/message.dart';
import 'package:chat_app/data/model/room.dart';
import 'package:chat_app/data/model/user.dart';
import 'package:chat_app/helper/shared_preferences.dart';
import 'package:chat_app/helper/socket_helper.dart';
import 'package:chat_app/providers/shuffle_provider.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/router/routes.dart';
import 'package:chat_app/screen/shuffle/component/card_shuffle.dart';
import 'package:chat_app/screen/shuffle/component/ic_avatar.dart';
import 'package:chat_app/screen/signin/component/dialog_loading.dart';
import 'package:chat_app/screen/signin/ui/signin.dart';
import 'package:chat_app/services/api_service.dart';
import 'package:chat_app/utils/notification_api.dart';
import 'package:chat_app/utils/user_security_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class Shuffle extends StatefulWidget {
  @override
  ShuffleState createState() {
    return ShuffleState();
  }
}

class ShuffleState extends State<StatefulWidget> {
  ApiService serviceManager = ApiService();
  int _selectedIndex = 0;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  var userID = "";

  DatabaseHelper databaseHelper = DatabaseHelper();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel("", "",
      importance: Importance.high, playSound: true);

  List<UserPerson> listRoom = [
    UserPerson(id: "1", name: "", email: "", createdAt: "", picture: URL_ICON)
  ];

  late Connectivity connectivity;
  late StreamSubscription<ConnectivityResult> subscription;

  bool _isLoading = true;

  Widget _buildDialog(BuildContext context) {
    return AlertDialog(
      content: Text(""),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  Future<dynamic> onSelectNotification(payload) async {
    if (payload == 'chat') {}
  }

  @override
  void initState() {
    print("Hello");

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      var messageRoom = MessageNotification.fromJson(message.data);

      if (notification != null &&
          android != null &&
          messageRoom.senderID != userID) {
        NotificationApi.showNotification(
            notification.title!, notification.body!);
      }

      AwesomeNotifications().actionStream.listen((event) {
        print("Notification " + event.toString());
        Navigator.pushNamed(context, CommonRoutes.MAIN, arguments: {"id": ''});
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      var messageRoom = MessageNotification.fromJson(message.data);

      Navigator.pushNamed(context, CommonRoutes.MAIN,
          arguments: {"id": messageRoom.roomID});
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {});

    _firebaseMessaging.getToken().then((token) async {
      final fcmToken = await SharedPreferencesHelper.shared.getFCMToken();

      print("TOKEN1 " + token!);

      if (userID == "") {
        userID = (await SharedPreferencesHelper.shared.getMyID())!;
      }

      if (fcmToken != token) {
        print("TOKEN2 " + token!);

        await serviceManager.saveToken(userID, token!, (data) async {
          var response = data as http.Response;

          print("TOKEN2 Body " + response.body);

          if (response.statusCode == 200) {
            /// Save Token Local
            await SharedPreferencesHelper.shared.setFCMToken(token);
          } else {}
        });
      }
    });

    connectivity = Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          print("Shuffle Connect " + result.toString());
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        SocketHelper.shared.connectSocket(userID);

        Provider.of<UserProvider>(context, listen: false)
            .getMe();
      }
    });

    init();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void init() {
    /// Get Me
    serviceManager.getMe((data) {
      var res = data as http.Response; // As Response

      /// Get Me Successfully
      if (res.statusCode == 200) {
        UserAccount account = UserAccount.fromJson(json.decode(res.body));

        /// Set Provider Account
        Provider.of<UserProvider>(context, listen: false)
            .setUserAccount(account);
        SocketHelper.shared.connectSocket(account.id);
      } else {
        if(res.statusCode == 401){
          showToast("The token is not invalid or out of date!", Colors.red);
          Navigator.pushReplacementNamed(context, CommonRoutes.SIGNIN);
        }
        else{
          showToast("", Colors.red);
          Navigator.pushReplacementNamed(context, CommonRoutes.SIGNIN);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var heightAppBar = AppBar().preferredSize.height;

    final roomShuffle = Provider.of<ShuffleProvider>(context);

    final userProvider = Provider.of<UserProvider>(context);

    final roomsBloc = BlocProvider.of<ShuffleBloc>(context);

    return WillPopScope(
        child: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            leadingWidth: 90,
            titleSpacing: -20,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.user!.name! == null
                      ? "User"
                      : userProvider.user.name!,
                  style: TextStyle(fontSize: 17),
                ),
              ],
            ),
            leading: Container(
                margin: const EdgeInsets.only(left: 5),
                child: Row(
                  children: [
                    icAvatar(
                        userProvider.user.picture,
                        heightAppBar * 0.7,
                        heightAppBar * 0.7,
                        () => {
                              Navigator.pushNamed(context, CommonRoutes.PROFILE)
                            })
                  ],
                )),
            actions: [
              GestureDetector(
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(Icons.arrow_forward),
                ),
                onTap: () async {
                  _signOut();
                },
              )
            ],
          ),
          body: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                _listShuffle(roomsBloc),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(

            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble), label: "Chatting")
            ],
            currentIndex: _selectedIndex,
            onTap: _tapItem,
          ),
        )),
        onWillPop: onBack());
  }

  void _tapItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  buildShuffle(){

  }

  _signOut() async {
    var userID = await SharedPreferencesHelper.shared.getMyID() as String;

    Dialogs.showLoadingDialog(context, _keyLoader);

    /// Set Token FCM
    await serviceManager.saveToken(userID, '', (data) async {
      var response = data as http.Response;

      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        print("TOKEN2 Body " + response.body);

        userID = "";

        /// Set Token Server
        await UserSecurityStorage.setToken("");
        // _socketHelper.disConnect();
        final FirebaseAuth _auth = FirebaseAuth.instance;
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await _auth.signOut();
        await googleSignIn.signOut();

        /// Remove Token
        await SharedPreferencesHelper.shared.removeToken();

        /// REMOVE FCM TOKEN
        await SharedPreferencesHelper.shared.setFCMToken("");

        /// Socket disconnect
        SocketHelper.shared.logout();

        /// Push to SIGN IN Screen
        Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => Signin(),
          ),
          (route) => false, //if you want to disable back feature set to false
        );
      } else {
        showToast("Cannot Sign Out !!!", Colors.red);
      }
    });
  }

  _listShuffle(ShuffleBloc bloc) {
    return BlocBuilder<ShuffleBloc, ShuffleBlocState>(
        bloc: bloc,
        builder: (BuildContext context, ShuffleBlocState state) {
          if (state is ShuffleLoadingState) {
            return const CircularProgressIndicator();
          }

          List<RoomShuffle>? rooms = null;

          if (state is ShuffleLoadedState) {
            rooms = (state as ShuffleLoadedState).rooms;
          }

          return Expanded(
              child: ListView.builder(
            itemCount: rooms!.length,
            controller: _scrollController,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var room = rooms![index];

              return CardShuffle(room, () {
                // Push to Main
                Navigator.pushNamed(context, CommonRoutes.MAIN);
              });
            },
          ));
        });
  }

  listShuffleProvider(List<RoomDB> items) {}

  onBack() {}

  void showToast(String message, Color color) {
    final snackBar = SnackBar(
        content: Text(
      message,
      style: TextStyle(color: color),
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
