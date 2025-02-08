import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _keyAccessToken = 'accessToken';

  /// 토큰 저장
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, token);
  }

  /// 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// 토큰 삭제
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
  }
}
