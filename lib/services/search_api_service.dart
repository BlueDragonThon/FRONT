import 'dart:convert';
import 'dart:ffi';
import 'package:bluedragonthon/utils/token_manager.dart';
import 'package:bluedragonthon/utils/university_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UniversityService {
  // .env에서 BASE_URL 가져오기
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'https://fallback.com';

  // 프로그램명으로 검색
  static Future<List<University>> searchProgram(
      String searchText, String endpoint) async {
    final String? token = await TokenManager.getToken();

    if (token == null) {
      throw Exception('No token found');
    }
    final Uri url = Uri.parse('$baseUrl$endpoint');

    final body = jsonEncode({
      "program": searchText,
      "page": 1,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['isSuccess'] == true) {
        final List<dynamic> results = jsonResponse['result']['result'];
        print(results);
        return results.map((data) => University.fromJson(data)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? '검색에 실패했습니다.');
      }
    } else {
      throw Exception('에러 발생: ${response.statusCode}');
    }
  }

  // 대학교명으로 검색
  static Future<List<University>> searchUniversity(
      String searchText, String endpoint) async {
    final String? token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final Uri url = Uri.parse('$baseUrl$endpoint');

    final body = jsonEncode({
      "name": searchText,
      "page": 1,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['isSuccess'] == true) {
        final List<dynamic> results = jsonResponse['result']['result'];
        return results.map((data) => University.fromJson(data)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? '검색에 실패했습니다.');
      }
    } else {
      throw Exception('에러 발생: ${response.statusCode}');
    }
  }

  /// 하트 토글 API 호출: 사용자 토큰을 id로 전송
  static Future<bool> toggleHeart(int universityId, bool currentState) async {
    final String? token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final Uri url = Uri.parse('$baseUrl/api/college/like');
    final body = jsonEncode({
      "collegeId": universityId,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return !currentState;
    } else {
      throw Exception('하트 요청 실패: ${response.statusCode}');
    }
  }

static Future<List<University>> sendLocationData({
  required double acr,
  required double dwn,
  int page = 0,
}) async {
  final Uri url = Uri.parse('$baseUrl/api/college/distance');

  final body = jsonEncode({
    "acr": acr,
    "dwn": dwn,
    "page": 1, // 혹은 page 매개변수를 사용할 수 있음
  });

   final String? token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'},
    body: body,
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    if (jsonResponse['isSuccess'] == true) {
      final List<dynamic> results = jsonResponse['result']['result'];
      return results.map((data) => University.fromJson(data)).toList();
    } else {
      throw Exception(jsonResponse['message'] ?? '검색에 실패했습니다.');
    }
  } else {
    throw Exception('Location API error: ${response.statusCode}');
  }
}
}
