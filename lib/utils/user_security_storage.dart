import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecurityStorage {
  static final _storage = FlutterSecureStorage();

  /// KEY TOKEN
  static const String _KEY_TOKEN = "TOKEN_JWT";

  static Future setToken(String token) async => 
      await _storage.write(key: _KEY_TOKEN, value: token);

  static Future<String?> getToken() async =>
      await _storage.read(key: _KEY_TOKEN);
}
