import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bluedragonthon/utils/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 강의 리뷰 모델
class ReviewItem {
  final int id;
  final String title;
  final String content;
  final String writer;
  final bool isUserCreated;

  ReviewItem({
    required this.id,
    required this.title,
    required this.content,
    required this.writer,
    required this.isUserCreated,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      writer: json['writer'] as String,
      isUserCreated: json['isUserCreated'] as bool,
    );
  }
}

/// 알림 아이템 구조 (기존 코드)
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

/// 찜한 대학 아이템 구조
class LikeUnivItem {
  final int id;
  final String name;
  final String headmaster;
  final String contactInfo;
  final String address;
  final List<String> program;
  final bool favorites;

  LikeUnivItem({
    required this.id,
    required this.name,
    required this.headmaster,
    required this.contactInfo,
    required this.address,
    required this.program,
    required this.favorites,
  });

  factory LikeUnivItem.fromJson(Map<String, dynamic> json) {
    return LikeUnivItem(
      id: json['id'] as int,
      name: json['name'] as String,
      headmaster: json['headmaster'] as String,
      contactInfo: json['contactInfo'] as String,
      address: json['address'] as String,
      program: (json['program'] as List<dynamic>)
          .map((p) => p as String)
          .toList(),
      favorites: json['favorites'] as bool,
    );
  }
}

/// 찜한 대학 목록 응답(result) 안쪽 구조
class LikeUnivResult {
  final List<LikeUnivItem> result;
  final int pageCount;

  LikeUnivResult({
    required this.result,
    required this.pageCount,
  });

  factory LikeUnivResult.fromJson(Map<String, dynamic> json) {
    return LikeUnivResult(
      result: (json['result'] as List<dynamic>)
          .map((item) => LikeUnivItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pageCount: json['pageCount'] as int,
    );
  }
}

/// 최상위 응답 구조 (isSuccess, code, message, result)
class LikeUnivListResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final LikeUnivResult result;

  LikeUnivListResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.result,
  });

  factory LikeUnivListResponse.fromJson(Map<String, dynamic> json) {
    return LikeUnivListResponse(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: LikeUnivResult.fromJson(json['result'] as Map<String, dynamic>),
    );
  }
}

// 회원가입 응답 구조들(기존 코드 그대로)
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

  /// (기존 예시) 회원가입
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

  /// (기존) 알림 목록 가져오기 (GET /api/notifications/get)
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
        'Authorization': 'Bearer $token',
      },
    );

    final String decodedBody = utf8.decode(response.bodyBytes);
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

  /// (기존) 알림 삭제 (DELETE /api/notifications/{notificationId})
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

  /// **찜한 대학 목록 가져오기** (POST /api/college/likeSearch?page={page})
  static Future<LikeUnivListResponse> getLikeUnivList(int page) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No Token found');
    }

    // Swagger 예시에 따르면, page를 query 파라미터로 사용
    final url = Uri.parse('$baseUrl/api/college/likeSearch?page=$page');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final String decodedBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(decodedBody);
      if (jsonBody['isSuccess'] == true) {
        return LikeUnivListResponse.fromJson(jsonBody);
      } else {
        throw Exception(jsonBody['message'] ?? 'Failed to get like univ list');
      }
    } else {
      throw Exception('Failed to get like univ list: ${response.statusCode}');
    }
  }

  /// **찜 해제** (DELETE /api/college/like?collegeId={collegeId})
  static Future<void> deleteLikeUniv(int collegeId) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No Token found');
    }

    // collegeId를 쿼리 파라미터로 붙여서 호출
    final url = Uri.parse('$baseUrl/api/college/like?collegeId=$collegeId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete (unfavorite) univ: ${response.statusCode}');
    }
  }

  // -----------------------------------------
// 리뷰 CRUD
// -----------------------------------------
  static Future<List<ReviewItem>> getReviews() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No Token found');
    }

    final url = Uri.parse('$baseUrl/api/review/read');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decodedBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(decodedBody);
      if (jsonBody['isSuccess'] == true) {
        final List<dynamic> results = jsonBody['result'];
        return results
            .map((item) => ReviewItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(jsonBody['message'] ?? 'Failed to get reviews');
      }
    } else {
      throw Exception('Failed to get reviews: ${response.statusCode}');
    }
  }

  static Future<void> createReview(String title, String content) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No Token found');
    }

    final url = Uri.parse('$baseUrl/api/review/create');
    final body = {
      'title': title,
      'content': content,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200 || decodedBody['isSuccess'] != true) {
      throw Exception(decodedBody['message'] ?? 'Failed to create review');
    }
  }

  static Future<void> updateReview(int reviewId, String title, String content) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No Token found');
    }

    final url = Uri.parse('$baseUrl/api/review/update');
    final body = {
      'reviewId': reviewId,
      'title': title,
      'content': content,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200 || decodedBody['isSuccess'] != true) {
      throw Exception(decodedBody['message'] ?? 'Failed to update review');
    }
  }

  static Future<void> deleteReview(int reviewId) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No Token found');
    }

    // Swagger 예시에 따르면 DELETE /api/review/get?reviewId=... 형태로 처리
    final url = Uri.parse('$baseUrl/api/review/get?reviewId=$reviewId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200 || decodedBody['isSuccess'] != true) {
      throw Exception(decodedBody['message'] ?? 'Failed to delete review');
    }
  }

  /// **대학 검색** (POST /api/college/search)
  static Future<LikeUnivListResponse> searchCollege({
    required int page,
  }) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No Token found');
    }

    // 저장해둔 위도/경도 불러오기
    final prefs = await SharedPreferences.getInstance();
    final double lat = prefs.getDouble('userLocationLat') ?? 0.0;
    final double lng = prefs.getDouble('userLocationLng') ?? 0.0;

    // body에 넣어주기
    final body = {
      'acr': lat,    // 서버 요구사항에 맞게 "acr"가 latitude라고 가정
      'dwn': lng,    // "dwn"이 longitude라고 가정
      'page': page,
    };

    final url = Uri.parse('$baseUrl/api/college/search');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final String decodedBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(decodedBody);
      if (jsonBody['isSuccess'] == true) {
        return LikeUnivListResponse.fromJson(jsonBody);
      } else {
        throw Exception(jsonBody['message'] ?? 'Failed to search college');
      }
    } else {
      throw Exception('Failed to search college: ${response.statusCode}');
    }
  }
}
