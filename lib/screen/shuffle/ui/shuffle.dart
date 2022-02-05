import 'dart:convert';

import 'package:chat_app/bloc/shuffle/shuffle_bloc.dart';
import 'package:chat_app/bloc/shuffle/shuffle_state.dart';
import 'package:chat_app/constants/constant.dart';
import 'package:chat_app/data/db/database_helper.dart';
import 'package:chat_app/data/model/room.dart';
import 'package:chat_app/data/model/user.dart';
import 'package:chat_app/helper/shared_preferences.dart';
import 'package:chat_app/helper/socket_helper.dart';
import 'package:chat_app/providers/room_provider.dart';
import 'package:chat_app/router/routes.dart';
import 'package:chat_app/screen/shuffle/component/card_shuffle.dart';
import 'package:chat_app/screen/shuffle/component/ic_avatar.dart';
import 'package:chat_app/screen/signin/component/dialog_loading.dart';
import 'package:chat_app/services/service_manager.dart';
import 'package:chat_app/utils/user_security_storage.dart';
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
  ServiceManager serviceManager = new ServiceManager();
  int _selectedIndex = 0;

  final SocketHelper _socketHelper = new SocketHelper();
  final ScrollController _scrollController = new ScrollController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  static var userID = "61fac924f510a60016b3e7f4";

  DatabaseHelper databaseHelper = DatabaseHelper();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel("", "",
      importance: Importance.high, playSound: true);

  List<UserPerson> listRoom = [
    UserPerson(id: "1", name: "", email: "", createdAt: "", picture: URL_ICON)
  ];

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

  Future<dynamic> onSelectNotification(payload) async{
    if(payload == 'main'){
      // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      //
      // }));
    }
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
                android: AndroidNotificationDetails("channel.id", "channel.name",
                    color: Colors.blue,
                    playSound: true,
                    icon: URL_ICON)));
      }
    });

    // final InitializationSettings initializationSettings = InitializationSettings(android: );

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      
      Navigator.pushNamed(context, CommonRoutes.MAIN, arguments: {

      });

    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {

      final fcmToken = await SharedPreferencesHelper.shared.getFCMToken();

      if(fcmToken != token){
        print("FCM TOKEN " + fcmToken!);

        await serviceManager.saveToken(userID, token, (data){
          var response = data as http.Response;


        });
      }
    });

    _firebaseMessaging.getToken().then((token) async{

      // final fcmToken = await SharedPreferencesHelper.shared.getFCMToken();

      print("FCM TOKEN " + token!);

      serviceManager.saveToken(userID, token!, (data){
        var response = data as http.Response;


      });

      // await print("FCM TOKEN " + fcmToken!);
      //
      //  if(fcmToken != token){
      //
      // }
    });

    init();

    // updateListView();
  }

  void init() {
    /// Get Me
    serviceManager.getMe((data) {
      var res = data as http.Response; // As Response

      /// Get Me Successfully
      if (res.statusCode == 200) {
        UserAccount account = UserAccount.fromJson(json.decode(res.body));
        _socketHelper.connectSocket(account.id);
      } else {
        showToast("The token is valid or out of date!", Colors.red);
        Navigator.pushReplacementNamed(context, CommonRoutes.SIGNIN);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var heightAppBar = AppBar().preferredSize.height;

    final roomsBloc = BlocProvider.of<ShuffleBloc>(context);

    return WillPopScope(
        child: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            leadingWidth: 90,
            titleSpacing: -15,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Chatting",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            leading: Container(
                margin: const EdgeInsets.only(left: 5),
                child: Row(
                  children: [
                    icAvatar(
                        URL_ICON,
                        heightAppBar * 0.8,
                        heightAppBar * 0.8,
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
                // RefreshIndicator(
                //     child: Consumer<RoomProvider>(
                //       builder: (context, roomProvider, child) =>
                //           roomProvider.items.isEmpty
                //               ? child!
                //               : listShuffleProvider(roomProvider.items),
                //       child: const Text("Error"),
                //     ),
                //     onRefresh: () =>
                //         context.read<RoomProvider>().fetchAllRoom())
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text("Home")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble), title: Text("Chatting"))
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

  _signOut() async {
    var userID = await SharedPreferencesHelper.shared.getMyID() as String;

    Dialogs.showLoadingDialog(context, _keyLoader);

    /// Set Token FCM
    await serviceManager.saveToken(userID, '', (data) async {
      var response = data as http.Response;

      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        /// Set Token Server
        await UserSecurityStorage.setToken("");
        // _socketHelper.disConnect();
        final FirebaseAuth _auth = FirebaseAuth.instance;
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await _auth.signOut();
        await googleSignIn.signOut();

        /// Remove Token
        await SharedPreferencesHelper.shared.removeToken();

        /// Socket disconnect
        SocketHelper.shared.logout();

        /// Push to SIGN IN Screen
        Navigator.pushReplacementNamed(context, CommonRoutes.SIGNIN);
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
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: color,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
