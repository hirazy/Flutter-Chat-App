import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_app/bloc/message/messages_bloc.dart';
import 'package:chat_app/bloc/message/messages_event.dart';
import 'package:chat_app/bloc/message/messages_state.dart';
import 'package:chat_app/bloc/shuffle/shuffle_bloc.dart';
import 'package:chat_app/bloc/shuffle/shuffle_state.dart';
import 'package:chat_app/data/db/database_helper.dart';
import 'package:chat_app/data/model/file_name.dart';
import 'package:chat_app/data/model/message.dart';
import 'package:chat_app/data/model/room.dart';
import 'package:chat_app/helper/shared_preferences.dart';
import 'package:chat_app/helper/socket_helper.dart';
import 'package:chat_app/router/routes.dart';
import 'package:chat_app/screen/main/component/chat_message.dart';
import 'package:chat_app/screen/profile/ui/profile.dart';
import 'package:chat_app/screen/shuffle/component/ic_avatar.dart';
import 'package:chat_app/screen/shuffle/ui/shuffle.dart';
import 'package:chat_app/screen/signin/ui/signin.dart';
import 'package:chat_app/screen/signup/ui/signup.dart';
import 'package:chat_app/services/service_manager.dart';
import 'package:chat_app/utils/user_security_storage.dart';
import 'package:chat_app/viewmodel/chat/chat_view_model.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

import '../../../constants/constant.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel("", "",
    importance: Importance.high, playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

Future<void> _firebaseMessagingBackground(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("A bg message just showed up: ${message.messageId}");
}

/// My App
class MyApp extends StatelessWidget {
  /// Get JWT Token
  Future<String?> get jwtOrEmpty async {
    return UserSecurityStorage.getToken();
  }

  var listRoom = List<RoomShuffle>.from([
    RoomShuffle(
      id: "61d5204483cef30016d260f6",
      picture: URL_ICON,
      name: 'Chat Chung',
      recentMessage: "You sent message.",
      isSeen: true
    ),
  ]);

  /// Init firebase and get me
  @override
  void initState() {

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (notification != null && android != null) {

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails("1", channel.name,
                    color: Colors.blue,
                    playSound: true,
                    icon: URL_ICON)));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Navigator.pushNamed(, CommonRoutes.MAIN, arguments: {
      // 'id': ''
      // });

    });

    _firebaseMessaging.getToken().then((token) {
      print("Token " + token!); // Print the Token in Console
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: jwtOrEmpty,
        builder: (context, snapShot) {
          if (snapShot.data != null && snapShot.data != "") {
            var str = snapShot.data as String;
            var jwt = str.split("");

            if (jwt.length != 3) {} else {
              var payload = json.decode(
                  ascii.decode(base64.decode(base64.normalize(jwt[1]))));
              if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                  .isAfter(DateTime.now())) {
                return BlocProvider(
                    create: (context) =>
                        ShuffleBloc(ShuffleLoadedState(listRoom)),
                    child: Shuffle());
              } else {
                return Signin();
              }
            }
          } else {
            return Signin();
          }
          return BlocProvider(
              create: (context) => ShuffleBloc(ShuffleLoadedState(listRoom)),
              child: Shuffle());
        },
      ),
      routes: {
        CommonRoutes.MAIN: (context) =>
            BlocProvider(
              create: (context) =>
                  MessageBloc(
                      MessageStateLoading(), '61d5204483cef30016d260f6'),
              child: MyHomePage(
                title: '',
              ),
            ),
        CommonRoutes.SIGNIN: (context) => Signin(),
        CommonRoutes.SIGNUP: (context) => SignUp(),
        CommonRoutes.SHUFFLE: (context) =>
            BlocProvider(
              create: (context) => ShuffleBloc(ShuffleLoadedState(listRoom)),
              child: Shuffle(),
            ),
        CommonRoutes.PROFILE: (context) => Profile()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // Bloc manage
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Bloc manage
  int _counter = 0;
  bool show = false;
  bool emojiShowing = false;
  TextEditingController _controllerText = TextEditingController();
  FocusNode focusNode = FocusNode();
  ScrollController _scrollController = new ScrollController();
  ServiceManager serviceManager = new ServiceManager();
  static var roomID = "61d5204483cef30016d260f6";
  static var userID = "61fac924f510a60016b3e7f4";


  // DatabaseHelper databaseHelper = DatabaseHelper();

  var listMessage = List.from([
    MessageChat(
        content: "content", isMy: true, createdAt: "createdAt", isImage: false),
    MessageChat(
        content: "sasas", isMy: false, createdAt: "createdAt", isImage: false),
    MessageChat(
        content: "sasas", isMy: false, createdAt: "createdAt", isImage: false),
  ]);

  /// Init firebase and get me
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
            NotificationDetails(
                android: AndroidNotificationDetails("channel.id", "channel.name",
                    color: Colors.blue,
                    playSound: true,
                    icon: URL_ICON)),
            payload:  CommonRoutes.MAIN
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      Navigator.pushNamed(context, CommonRoutes.MAIN, arguments: {

      });
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {

      final fcmToken = await SharedPreferencesHelper.shared.getFCMToken();

      print("FCM TOKEN " + fcmToken!);

      if(fcmToken != token){
        serviceManager.saveToken(userID, token, (data) async{
          var response = data as http.Response;
          if(response.statusCode == 200){
            await SharedPreferencesHelper.shared.setFCMToken(token);
          }

        });
      }
    });

    _firebaseMessaging.getToken().then((token) async{

      final fcmToken = await SharedPreferencesHelper.shared.getFCMToken();

      if(fcmToken != token){
        serviceManager.saveToken(userID, token!, (data) async{
          var response = data as http.Response;
          if(response.statusCode == 200){
            await SharedPreferencesHelper.shared.setFCMToken(token);
          }
        });
      }
    });

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });
  }

  Future init() async {
    userID = await SharedPreferencesHelper.shared.getMyID() as String;

    /// Fetch Room Current
    showToast("Get Room", Colors.blue);
    await serviceManager.fetchRoom(roomID, (data) {

      var response = data as http.Response;

      /// Fetch Room Successful
      if (response.statusCode == 200) {
        /// Save database

        var room = Room.fromJson(jsonDecode(response.body));

        // databaseHelper.updateRoom(room);
        
        listMessage = [];
        for (int i = 0; i < room.messages.length; i++) {
          listMessage.add(MessageChat(
              content: room.messages[i].content,
              isMy: room.messages[i].senderID == "61b4caca9d95e5001672e9ed",
              createdAt: "",
              isImage: room.messages[i].isImage));
        }

        listMessage = room.messages;

        print(listMessage.toString());

        // listMessage = response.body;

      } else {
        showToast("Get Failed", Colors.red);
      }
    });
  }

  var heightAppBar = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      MessageBloc(MessageStateLoading(), roomID)
        ..add(LoadingMessagesEvent()),
      child: FutureBuilder(
        builder: (context, snapshot) {
          return WillPopScope(
            child: SafeArea(
              child: Scaffold(
                  extendBodyBehindAppBar: false,
                  appBar: AppBar(
                    leadingWidth: 90,
                    titleSpacing: 0,
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Hirazy2001",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text("last seen today at 12",
                            style: TextStyle(fontSize: 12))
                      ],
                    ),
                    leading: Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Row(
                          children: [
                            InkWell(
                              child: const Icon(Icons.arrow_back, size: 24),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            icAvatar(URL_ICON, heightAppBar * 0.8, heightAppBar * 0.8, (){

                            })
                          ],
                        )),
                    actions: [
                      GestureDetector(
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.videocam),
                        ),
                        onTap: () {},
                      ),
                      GestureDetector(
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.call),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                  body: Container(
                    color: Colors.white,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Column(
                      children: [
                        _chatTextArea(context),
                        _bottomChatArea(context),
                        //_emojiSelect()
                      ],
                    ),
                  )),
            ),
            onWillPop: _onBackspacePressed(),
          );
        },
        future: init(),
      ),
    );
  }

  _chatTextArea(BuildContext context) {
    var blocMessage = BlocProvider.of<MessageBloc>(context);

    return BlocBuilder<MessageBloc, MessageState>(
        bloc: blocMessage,
        builder: (BuildContext context, MessageState state) {
          if (state is MessageStateLoading) {
            /// Loading

            return const Expanded(
                child: SizedBox(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                  height: 200.0,
                  width: 200.0,
                ));
          } else if (state is MessageStateLoaded) {
            /// Loaded Successful

            List<MessageChat>? messageState = [];
            List<MessageRoom> messages = state.messages;

            for (int i = 0; i < messages.length; i++) {
              messageState!.add(MessageChat(
                  content: messages[i].content,
                  createdAt: '',
                  isMy: messages[i].senderID == userID,
                  isImage: messages[i].isImage));
            }

            messageState = messageState.reversed.toList();

            return Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: messageState!.length,
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var mess = messageState![index];

                    return ChatMessage(
                        message: ChatViewModel(message: mess), isMy: mess.isMy)
                        .buildText(context);
                  },
                ));
          } else if (state is MessageStateLoadFailed) {
            /// Failed
            return Expanded(
                child: Center(
                  child: Text(state.error),
                ));
          }

          /// Load More
          return const Expanded(
              child: Center(
                child: Text("Loading..."),
              ));
        });
  }

  _bottomChatArea(context) {
    var blocMessage = BlocProvider.of<MessageBloc>(context);
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            padding: const EdgeInsets.only(top: 5),
            margin: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.wallpaper,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () async {
                    PickedFile? file = await ImagePicker().getImage(
                        source: ImageSource.gallery,
                        maxHeight: 1800,
                        maxWidth: 1800);

                    File imageFile = File(file!.path); //convert Path to File
                    Uint8List imageBytes =
                    await imageFile.readAsBytes(); //convert to bytes
                    String base64string = base64.encode(imageBytes);

                    var messageImage = MessageRoom(
                        senderID: userID, content: base64string, isImage: true);

                    blocMessage.add(AddMessageEvent(messageImage));

                    /// Upload image to server
                    await serviceManager.uploadImageMessage(imageFile, (data) async{
                      var response = data as http.Response;


                      if (response.statusCode == 200) {

                        var fileName = FileName.fromJson(jsonDecode(response.body));

                        print("File Name " + fileName.name);

                        /// Get name of file image which save on server
                        var message = MessageRoom(senderID: userID,
                            content: fileName.name, isImage: true);

                        /// Add message to server
                        await serviceManager.sendMessage(
                            roomID, message, (data) {
                          showToast("message", Colors.red);

                          var response = data as http.Response;

                          /// Send Message to Database Successfully
                          if (response.statusCode == 200) {
                            /// Save database
                            ///
                            SocketHelper.shared.sendMessage(
                                roomID: roomID,
                                receiverID: "",
                                message: fileName.name,
                                isImage: true);

                            print("Successful!!!");
                          } else {
                            /// Cannot put message
                          }
                        });
                      }
                      else {
                        /// Cannot put image
                      }
                    });
                  },
                ),
                Flexible(
                    child: Container(
                        child: Card(
                            color: Colors.white70,
                            margin: const EdgeInsets.only(left: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            child: TextFormField(
                              controller: _controllerText,
                              focusNode: focusNode,
                              textAlign: TextAlign.start,
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 1,
                              autocorrect: false,
                              decoration: InputDecoration(
                                  prefixIcon: IconButton(
                                    icon: Icon(
                                      show
                                          ? Icons.keyboard
                                          : Icons.emoji_emotions_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (!show) {
                                          focusNode.unfocus();
                                          focusNode.canRequestFocus = false;
                                        }
                                        setState(() {
                                          show = !show;
                                        });
                                      });
                                    },
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.attach_file),
                                        onPressed: () {
                                          showModalBottomSheet(
                                              backgroundColor:
                                              Colors.transparent,
                                              context: context,
                                              builder: (builder) =>
                                                  bottomSheet());
                                        },
                                      )
                                    ],
                                  ),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: "Chat here"),
                            )))),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.send,
                      color: Colors.blueAccent,
                    ),
                  ),
                  onTap: () {
                    var textSend = _controllerText.value.text.trim();
                    if (textSend != '') {
                      var message = MessageRoom(
                          content: textSend, isImage: false, senderID: userID);

                      // Bloc Add Message
                      blocMessage.add(AddMessageEvent(message));
                      _controllerText.text = '';

                      showToast("message " + message.content + " " + roomID,
                          Colors.blue);

                      serviceManager.sendMessage(roomID, message, (data) {
                        showToast("message", Colors.red);

                        var response = data as http.Response;

                        /// Send Message to Database Successfully
                        if (response.statusCode == 200) {
                          /// Save database

                          /// Send socket emit to room
                          SocketHelper.shared.sendMessage(
                              roomID: roomID,
                              receiverID: "",
                              message: textSend,
                              isImage: false);
                        } else {}
                      });
                    }
                  },
                )
              ],
            )));
  }

  _onBackspacePressed() {
    _controllerText
      ..text = _controllerText.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controllerText.text.length));
  }

  _onEmojiSelected(Emoji emoji) {
    _controllerText
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controllerText.text.length));
  }

  _emojiSelect() {
    return Offstage(
      offstage: !emojiShowing,
      child: SizedBox(
        height: 250,
        child: EmojiPicker(
            onEmojiSelected: (Category category, Emoji emoji) {
              _onEmojiSelected(emoji);
            },
            onBackspacePressed: _onBackspacePressed,
            config: Config(
                columns: 7,
                emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                verticalSpacing: 0,
                horizontalSpacing: 0,
                initCategory: Category.RECENT,
                bgColor: const Color(0xFFF2F2F2),
                indicatorColor: Colors.blue,
                iconColor: Colors.grey,
                iconColorSelected: Colors.blue,
                progressIndicatorColor: Colors.blue,
                backspaceColor: Colors.blue,
                showRecentsTab: true,
                recentsLimit: 28,
                noRecentsText: 'No Recents',
                noRecentsStyle:
                const TextStyle(fontSize: 20, color: Colors.black26),
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
                buttonMode: ButtonMode.MATERIAL)),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.location_pin, Colors.teal, "Location"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
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

  // void updateListView() {
  //   final Future<Database> dbFuture = databaseHelper.initializeDatabase();
  //   dbFuture.then((database) {
  //     Future<List<Room>> noteListFuture = databaseHelper.getRooms();
  //     noteListFuture.then((roomList) {
  //       setState(() {
  //
  //
  //       });
  //     });
  //   });
  // }

}
