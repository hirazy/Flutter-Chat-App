import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  late SharedPreferences _pref;
  static var shared = SharedPreferencesHelper();

  // Get User Token
  Future<String?> getUserToken() async{
    _pref = await SharedPreferences.getInstance();
    var token = _pref.getString('token');
    return token;
  }

  Future<void> setFCMToken(String token) async{
    _pref = await SharedPreferences.getInstance();
    _pref.setString('FCMToken', token);
    _pref.commit();
  }

  Future<String?> getFCMToken() async{
    _pref = await SharedPreferences.getInstance();
    var token = _pref.getString('FCMToken');
    return token;
  }

  // Get ID Token
  Future<String?> getMyID ()async{
    _pref = await SharedPreferences.getInstance();
    var id = _pref.getString('myID');
    return id;
  }

  Future<void> saveMyID(String id) async{
    _pref = await SharedPreferences.getInstance();
    _pref.setString('myID', id);
    _pref.commit();
  }

  // Remove Token
  Future<void> removeToken() async{
    _pref = await SharedPreferences.getInstance();
    _pref.remove('myID');
    _pref.remove('token');
    _pref.commit();
  }


}