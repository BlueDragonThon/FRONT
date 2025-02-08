import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 회원가입 API 응답 구조
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
  // .env 에서 BASE_URL 읽기
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://fallback.com';

  /// 멤버 정보 저장 후 토큰 받아오기
  static Future<SignupResponse> signupMember(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/api/member/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print(response.statusCode);
    print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SignupResponse.fromJson(data);
    } else {
      throw Exception('Failed to sign up: ${response.statusCode}');
    }
  }
}
