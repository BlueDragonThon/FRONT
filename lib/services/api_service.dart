import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bluedragonthon/utils/token_manager.dart';

/// 알림 아이템 구조
class NotificationItem {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String date;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.date,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
    );
  }
}

/// 기존 회원가입 응답 구조들 (생략했던 부분 그대로 두시면 됩니다.)
class SignupResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final SignupResult? result;

  SignupResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.result,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: json['result'] == null
          ? null
          : SignupResult.fromJson(json['result'] as Map<String, dynamic>),
    );
  }
}

/// 회원가입 후 반환되는 result 구조
class SignupResult {
  final int id;
  final String name;
  final String token;

  SignupResult({
    required this.id,
    required this.name,
    required this.token,
  });

  factory SignupResult.fromJson(Map<String, dynamic> json) {
    return SignupResult(
      id: json['id'] as int,
      name: json['name'] as String,
      token: json['token'] as String,
    );
  }
}

class ApiService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://fallback.com';

  /// (기존에 있던 회원가입 로직 예시)
  static Future<SignupResponse> signupMember(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/api/member/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SignupResponse.fromJson(data);
    } else {
      throw Exception('Failed to sign up: ${response.statusCode}');
    }
  }

  /// **알림 목록 가져오기** (GET /api/notifications/get)
  static Future<List<NotificationItem>> getNotifications() async {
    final token = await TokenManager.getToken(); // 토큰 불러오기
    if (token == null) {
      throw Exception('No Token found');
    }

    final url = Uri.parse('$baseUrl/api/notifications/get');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 필요한 형태로 조정
      },
    );

    // 응답 바이트를 UTF-8 문자열로 디코딩
    final String decodedBody = utf8.decode(response.bodyBytes);

    print(response.statusCode);
    print(decodedBody);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(decodedBody);
      if (jsonBody['isSuccess'] == true) {
        final List<dynamic> results = jsonBody['result'] as List<dynamic>;
        return results.map((item) {
          return NotificationItem.fromJson(item as Map<String, dynamic>);
        }).toList();
      } else {
        throw Exception(jsonBody['message'] ?? 'Failed to get notifications');
      }
    } else {
      throw Exception('Failed to get notifications: ${response.statusCode}');
    }
  }

  /// **알림 삭제** (DELETE /api/notifications/{notificationId})
  static Future<void> deleteNotification(int notificationId) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No Token found');
    }

    final url = Uri.parse('$baseUrl/api/notifications/$notificationId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification: ${response.statusCode}');
    }
  }
}