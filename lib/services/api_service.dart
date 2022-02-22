import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:async/async.dart';
import 'package:chat_app/data/model/message.dart';
import 'package:chat_app/utils/user_security_storage.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../constants/constant.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class ServiceManager {
  static final shared = ServiceManager();
  final header = {"Content-Type": "application/json"};
  GoogleSignInAccount? _currentUser;
  late final List<MessageChat> messageList;

  String ROUTE_AUTH = "/auth/";
  String ROUTE_USER = "/users/";

  String ROUTE_SIGNUP = "/users";
  String ROUTE_GETME = "/users/me";
  String ROUTE_GET_ROOM = "/rooms/";
  String ROUTE_ADD_MESSAGE = "/rooms/";
  String ROUTE_POST_IMAGE = "/images/";
  String ROUTE_UPDATE_PASSWORD = '/users/me/password';
  String ROUTE_USER_TOKEN = '/token';

  String DEFAULT_PASSWORD = "default_123";

  Future<void> singInGoogle() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;

      if (_currentUser != null) {}
    });
    return _googleSignIn.signInSilently();
  }

  /// Signup User
  Future<dynamic> signup_User(email, password, name, picture, callBack) async {
    var body = {
      'email': email,
      'password': password,
      'name': name,
      'picture': picture,
      'role': 'user'
    };

    /// Authorize Master
    var header = {'Authorization': 'Bearer ' + MASTER_KEY};

    final response = await http.post(Uri.parse(URL_BASE + ROUTE_SIGNUP),
        headers: header, body: body);

    /**
     * Result Sign up
     */

    await callBack(response);
  }

  /// Sign in User by email
  Future<dynamic> signin_User(String email, String password, callBack) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$email:$password'));

    Map<String, dynamic> formMap = {"access_token": MASTER_KEY};

    var response = await http.post(
      Uri.parse(URL_BASE + ROUTE_AUTH),
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
      },
      body: formMap,
      encoding: convert.Encoding.getByName("utf-8"),
    );

    await callBack(response);
  }

  /// Get Me by Token
  Future<dynamic> getMe(callBack) async {
    var token = await UserSecurityStorage.getToken();

    if (token != '') {
      Fluttertoast.showToast(
        msg: "Hey " + token!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      var header = {'Authorization': 'Bearer ' + token!};

      var response =
          await http.get(Uri.parse(URL_BASE + ROUTE_GETME), headers: header);
      await callBack(response);
    }
  }

  Future<dynamic> sendMessage(roomID, MessageRoom message, callBack) async {
    var messageSend = {
      'content': message.content,
      'senderID': message.senderID,
      'isImage': message.isImage,
    };

    var header = {
      'Authorization': 'Bearer ' + MASTER_KEY,
      "Content-Type": "application/json"
    };

    var response = await http.put(
      Uri.parse(URL_BASE + ROUTE_ADD_MESSAGE + roomID),
      headers: header,
      body: jsonEncode(messageSend),
    );

    await callBack(response);
  }

  /// Upload file image to server
  Future<dynamic> uploadImageMessage(File file, callBack) async {
    var uri = Uri.parse(URL_BASE + ROUTE_POST_IMAGE);

    var headers = {
      'Authorization': 'Bearer ' + MASTER_KEY,
      'Cookie': 'Cookie_1=value'
    };
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', file.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    var res = await http.Response.fromStream(response);

    await callBack(res);
  }

  Future<dynamic> updatePassword(
      String email, String curPassword, String newPassword, callBack) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$email:$curPassword'));

    var headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
      'Cookie': 'Cookie_1=value'
    };
    var request =
        http.Request('PUT', Uri.parse(URL_BASE + ROUTE_UPDATE_PASSWORD));
    request.body = json.encode({"password": newPassword});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    callBack(response);
  }

  Future<dynamic> saveToken(String userID, String token, callBack) async {
    var uri = Uri.parse(URL_BASE + ROUTE_USER + userID + "/token");

    var header = {'Authorization': 'Bearer ' + MASTER_KEY};
    var body = {'token': token};

    var response = await http.put(uri, headers: header, body: jsonEncode(body));

    callBack(response);
  }

  /// Fetch Message List
  Future<dynamic> fetchRoom(String roomID, callBack) async {
    var header = {'Authorization': 'Bearer ' + MASTER_KEY};

    var response = await http.get(Uri.parse(URL_BASE + ROUTE_GET_ROOM + roomID),
        headers: header);

    await callBack(response);
  }

  /// Fetch Message List
  Future<dynamic> fetchRoomRes(String roomID) async {
    var header = {'Authorization': 'Bearer ' + MASTER_KEY};

    var response = await http.get(Uri.parse(URL_BASE + ROUTE_GET_ROOM + roomID),
        headers: header);

    return response;
  }
}
