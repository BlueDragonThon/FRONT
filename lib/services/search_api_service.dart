import 'dart:convert';
import 'package:bluedragonthon/utils/token_manager.dart';
import 'package:bluedragonthon/utils/university_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UniversityService {
  // .env에서 BASE_URL 가져오기
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  /// 검색 API 호출: 요청 바디는 { "program": searchText, "page": 1 }
  /// 헤더에 token을 포함하여 POST 방식으로 호출합니다.
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
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
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

  static Future<List<University>> searchUniversity(
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
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
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
    final Uri url = Uri.parse('$baseUrl/api/colleage/like');

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

  /// 위치 데이터 전송 API 호출
  /// 요청 바디:
  /// {
  ///   "id": <사용자 토큰>,
  ///   "name": "string",
  ///   "age": 100,
  ///   "coordinate": {"acr": <acr 값>, "dwn": <dwn 값>}
  /// }
  static Future<dynamic> sendLocationData({
    required double acr,
    required double dwn,
    int page = 0,
  }) async {
    final String? token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final Uri url = Uri.parse('$baseUrl/api/colleage/search');

    final body = jsonEncode({
      "id": token,
      "name": "string",
      "age": 100,
      "coordinate": {
        "acr": acr,
        "dwn": dwn,
      }
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Location API error: ${response.statusCode}');
    }
  }
}
