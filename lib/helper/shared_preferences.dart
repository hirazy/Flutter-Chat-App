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

  // Get ID Token
  Future<String?> getMyID ()async{
    _pref = await SharedPreferences.getInstance();
    var id = _pref.getString('myID');
    return id;
  }

  // Remove Token
  Future<String?> removeToken() async{
    _pref = await SharedPreferences.getInstance();
    _pref.remove('myID');
    _pref.remove('token');
  }


}