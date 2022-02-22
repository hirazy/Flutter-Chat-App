import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_app/bloc/message/messages_bloc.dart';
import 'package:chat_app/bloc/message/messages_state.dart';
import 'package:chat_app/bloc/shuffle/shuffle_bloc.dart';
import 'package:chat_app/bloc/shuffle/shuffle_state.dart';
import 'package:chat_app/data/model/file_name.dart';
import 'package:chat_app/data/model/message.dart';
import 'package:chat_app/data/model/room.dart';
import 'package:chat_app/helper/shared_preferences.dart';
import 'package:chat_app/helper/socket_helper.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/room_provider.dart';
import 'package:chat_app/providers/shuffle_provider.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/router/routes.dart';
import 'package:chat_app/screen/main/component/chat_message.dart';
import 'package:chat_app/screen/main/component/page_image.dart';
import 'package:chat_app/screen/profile/ui/profile.dart';
import 'package:chat_app/screen/shuffle/component/ic_avatar.dart';
import 'package:chat_app/screen/shuffle/ui/shuffle.dart';
import 'package:chat_app/screen/signin/ui/signin.dart';
import 'package:chat_app/screen/signup/ui/signup.dart';
import 'package:chat_app/services/api_service.dart';
import 'package:chat_app/utils/user_security_storage.dart';
import 'package:chat_app/viewmodel/chat/chat_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:provider/provider.dart';

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
        isSeen: true),
  ]);

  /// Init firebase and get me
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((message) {});

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
    });

    _firebaseMessaging.getToken().then((token) async {
      print("Token " + token!); // Print the Token in Console
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ShuffleProvider()),
        ChangeNotifierProvider(create: (ctx) => RoomProvider()),
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
        StreamProvider(
          create: (context) => Connectivity().onConnectivityChanged,
          initialData: null,
        )
      ],
      child: MaterialApp(
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

              if (jwt.length != 3) {
              } else {
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
          CommonRoutes.MAIN: (context) => BlocProvider(
                create: (context) => MessageBloc(
                    MessageStateLoading(), '61d5204483cef30016d260f6'),
                child: const MyHomePage(
                  title: '',
                  id: '',
                ),
              ),
          CommonRoutes.SIGNIN: (context) => Signin(),
          CommonRoutes.SIGNUP: (context) => SignUp(),
          CommonRoutes.SHUFFLE: (context) => BlocProvider(
                create: (context) => ShuffleBloc(ShuffleLoadedState(listRoom)),
                child: Shuffle(),
              ),
          CommonRoutes.PROFILE: (context) => Profile()
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.id})
      : super(key: key);

  // Bloc manage
  final String title;

  final String id;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  // Bloc manage

  bool show = false;
  bool emojiShowing = false;
  final TextEditingController _controllerText = TextEditingController();
  FocusNode focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  ApiService serviceManager = ApiService();
  static var roomID = "61d5204483cef30016d260f6";
  var userID = "";
  bool _isLoading = true;

  late Connectivity connectivity;
  late StreamSubscription<ConnectivityResult> subscription;

  // DatabaseHelper databaseHelper = DatabaseHelper();

  /// Init firebase and get me
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      var messageRoom = MessageNotification.fromJson(message.data);

      var room = Provider.of<RoomProvider>(context, listen: false).room;

      if (room!.id == messageRoom.roomID && userID != messageRoom.senderID) {
        print("Add Message");

        /// Add message
        Provider.of<RoomProvider>(context, listen: false).addMessage(
            MessageRoom(
                content: messageRoom.content,
                isImage: messageRoom.isImage == "true" ? true : false,
                senderID: messageRoom.senderID));
      }
    });

    _firebaseMessaging.getToken().then((token) async {
      final fcmToken = await SharedPreferencesHelper.shared.getFCMToken();

      if (userID == "") {
        userID = (await SharedPreferencesHelper.shared.getMyID())!;
      }

      if (fcmToken != token) {
        serviceManager.saveToken(userID, token!, (data) async {
          var response = data as http.Response;
          if (response.statusCode == 200) {
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

    connectivity = Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      print("Main Connect " + result.toString());
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        Provider.of<RoomProvider>(context, listen: false)
            .fetchRoom(roomID, true);
      } else {}
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  var heightAppBar = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
    Provider.of<RoomProvider>(context).fetchRoom(roomID, false).then((value) {
      _isLoading = false;
    });

    final roomData = Provider.of<RoomProvider>(context);

    return WillPopScope(
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          leadingWidth: 90,
          titleSpacing: 0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roomData.room == null ? "Room" : roomData.room!.name,
                style: TextStyle(fontSize: 15),
              ),
              Text(
                  roomData.room == null
                      ? "Updated"
                      : roomData.room!.updatedTime,
                  style: const TextStyle(fontSize: 12))
            ],
          ),
          leading: Container(
              margin: const EdgeInsets.only(left: 5),
              child: Row(
                children: [
                  InkWell(
                    child: const Icon(Icons.arrow_back, size: 24),
                    onTap: () {
                      Provider.of<RoomProvider>(context, listen: false)
                          .outRoom();
                      userID = "";
                      Navigator.of(context).pop(true);
                    },
                  ),
                  icAvatar(
                      URL_ICON, heightAppBar * 0.8, heightAppBar * 0.8, () {})
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
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              _isLoading
                  ? const Expanded(
                      child: SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                      height: 200.0,
                      width: 200.0,
                    ))
                  : _areaMessage(roomData.room),
              // _chatTextArea(context),
              _bottomChatArea(context),
              //_emojiSelect()
            ],
          ),
        ),
      ),
      onWillPop: () async {
        print("Logout");
        Provider.of<RoomProvider>(context, listen: false).outRoom();
        userID = "";
        return true;
      },
    );
  }

  _areaMessage(Room? roomData) {
    List<MessageChat>? messageState = [];
    List<MessageRoom> messages = roomData!.messages;

    for (int i = 0; i < messages.length; i++) {
      messageState!.add(MessageChat(
          senderID: messages[i].senderID,
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
        var message = messageState![index];

        if (index > 0) {
          if (messageState[index].senderID ==
              messageState[index - 1].senderID) {
            return GestureDetector(
              child: ChatMessage(
                message: ChatViewModel(message: message),
                isMy: message.isMy,
                showAva: false,
              ),
              onTap: () {
                if (message.isImage == true) {
                  print("Tap Image");
                  List<dynamic> dataImages = _listImage(messageState!, index);
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
                  showDialog(
                    context: context,
                    builder: (context) => PageImage(
                        galleryItems: dataImages[0],
                        indexStart: dataImages[1]!),
                  ).then((value) {
                    if (value == null) return;
                  });
                }
              },
            );
          }
        }

        return GestureDetector(
          child: ChatMessage(
            message: ChatViewModel(message: message),
            isMy: message.isMy,
            showAva: true,
          ),
          onTap: () {
            if (message.isImage == true) {
              print("Tap Image");
              List<dynamic> dataImages = _listImage(messageState!, index);
              showDialog(
                context: context,
                builder: (context) => PageImage(
                    galleryItems: dataImages[0], indexStart: dataImages[1]!),
              );
            }
          },
        );
      },
    ));
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
                  senderID: messages[i].senderID,
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

                if (index < messageState.length - 1) {
                  if (messageState[index].senderID ==
                      messageState[index + 1].senderID) {
                    return ChatMessage(
                      message: ChatViewModel(message: mess),
                      isMy: mess.isMy,
                      showAva: false,
                    );
                  }
                }

                return ChatMessage(
                  message: ChatViewModel(message: mess),
                  isMy: mess.isMy,
                  showAva: true,
                );
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

                    // blocMessage.add(AddMessageEvent(messageImage));

                    /// Upload image to server
                    await serviceManager.uploadImageMessage(imageFile,
                        (data) async {
                      var response = data as http.Response;

                      if (response.statusCode == 200) {
                        var fileName =
                            FileName.fromJson(jsonDecode(response.body));

                        print("File Name " + fileName.name);

                        Provider.of<RoomProvider>(context, listen: false)
                            .addMessage(messageImage);

                        /// Get name of file image which save on server
                        var message = MessageRoom(
                            senderID: userID,
                            content: fileName.name,
                            isImage: true);

                        /// Add message to server
                        await serviceManager.sendMessage(roomID, message,
                            (data) {
                          var response = data as http.Response;

                          /// Send Message to Database Successfully
                          if (response.statusCode == 200) {
                            /// Save database
                            SocketHelper.shared.sendMessage(
                                senderID: userID,
                                roomID: roomID,
                                receiverID: "",
                                message: fileName.name,
                                isImage: true);
                          } else {
                            /// Cannot put message
                          }
                        });
                      } else {
                        /// Cannot put image
                        showToast("Please provide an image file!", Colors.red);
                      }
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultPadding * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sentiment_satisfied_alt_outlined,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .color!
                              .withOpacity(0.64),
                        ),
                        const SizedBox(width: kDefaultPadding / 4),
                        Expanded(
                          child: TextField(
                            minLines: 1,
                            autocorrect: false,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            cursorColor: Colors.black,
                            focusNode: focusNode,
                            controller: _controllerText,
                            decoration: const InputDecoration(
                              hintText: "Type message",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.attach_file,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .color!
                              .withOpacity(0.64),
                        ),
                        const SizedBox(width: kDefaultPadding / 4),
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .color!
                              .withOpacity(0.64),
                        ),
                      ],
                    ),
                  ),
                ),
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
                      // blocMessage.add(AddMessageEvent(message));

                      _controllerText.text = '';

                      Provider.of<RoomProvider>(context, listen: false)
                          .addMessage(message);

                      serviceManager.sendMessage(roomID, message, (data) {
                        var response = data as http.Response;

                        /// Send Message to Database Successfully
                        if (response.statusCode == 200) {
                          /// Save database

                          /// Send socket emit to room
                          SocketHelper.shared.sendMessage(
                              senderID: userID,
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

  List<dynamic> _listImage(List<MessageChat> list, int index) {
    List<String> itemImages = [];
    int indexStart = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i].isImage) {
        itemImages.add(list[i].content);
        if (index == i) {
          indexStart = itemImages.length - 1;
        }
      }
    }
    return [itemImages, indexStart];
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
      width: MediaQuery.of(context).size.width,
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

  Future<void> _refreshMessage(BuildContext context) async {
    await Provider.of<RoomProvider>(context, listen: false)
        .fetchRoom(roomID, false);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
