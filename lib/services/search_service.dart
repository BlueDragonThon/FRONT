// university_service.dart
import 'dart:convert';
import 'package:bluedragonthon/utils/university_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UniversityService {
  // .env에서 BASE_URL 가져오기
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  /// 검색 API 호출: endpoint는 '/university/search' 또는 '/course/search' 등으로 전달
  static Future<List<University>> searchUniversity(
      String searchText, String endpoint) async {
    final Uri url = Uri.parse('$baseUrl$endpoint/$searchText');
    print("베이스 주소 나오나 $url");

    // 실제 API 호출 예시 (주석 처리)
    /*
    final response = await http.get(url);
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
    */

    // 더미 데이터 처리
    await Future.delayed(const Duration(seconds: 2));
    final Map<String, dynamic> dummyResponse = {
      "isSuccess": true,
      "code": "dummy",
      "message": "dummy",
      "result": {
        "result": [
          {
            "id": 1,
            "name": "중앙대학교",
            "contactInfo": "010-2797-1090",
            "address": "서울특별시 동작구",
            "isHeart": false,
            "program": ["소프트웨어학부", "경영학부"]
          },
          {
            "id": 2,
            "name": "서울대학교",
            "contactInfo": "010-1111-2222",
            "address": "서울특별시 관악구",
            "isHeart": true,
            "program": ["컴퓨터공학", "의학"]
          }
        ],
        "pageCount": 1
      }
    };

    if (dummyResponse['isSuccess'] == true) {
      final List<dynamic> results = dummyResponse['result']['result'];
      return results.map((data) => University.fromJson(data)).toList();
    } else {
      throw Exception(dummyResponse['message'] ?? '검색에 실패했습니다.');
    }
  }

  /// 하트 토글 API 호출: 각 검색 페이지에서 사용
  static Future<bool> toggleHeart(int id, bool currentState) async {
    // 실제 API 호출 예시 (주석 처리)
    /*
    const String userToken = 'dummy-token';
    final Uri url = Uri.parse('$baseUrl/university/heart-toggle');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode({
        'id': id,
        'isHeart': !currentState,
      }),
    );
    if (response.statusCode == 200) {
      return !currentState;
    } else {
      throw Exception('하트 요청 실패: ${response.statusCode}');
    }
    */
    // 더미 처리
    await Future.delayed(const Duration(milliseconds: 500));
    return !currentState;
  }
}
