import 'dart:async';
import 'dart:convert';
import 'dart:math'; // 랜덤 뽑기용
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // <-- HapticFeedback을 사용하려면 추가
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bluedragonthon/services/api_service.dart';
import 'package:bluedragonthon/screens/reminder.dart';
import 'package:bluedragonthon/screens/search_gps.dart';
import 'package:bluedragonthon/screens/search_subject.dart';
import 'package:bluedragonthon/screens/search_univ.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  // -------------------------------------------------
  // "큰 글자 모드" 여부
  // (SharedPreferences에서 로드/저장)
  // -------------------------------------------------
  bool _isLargeText = false;

  // -------------------------------------------------
  // 공유 함수: "큰 글자 모드" 로드
  // -------------------------------------------------
  Future<void> _loadLargeTextSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLargeText = prefs.getBool('isLargeText') ?? false;
    });
  }

  // -------------------------------------------------
  // 공유 함수: "큰 글자 모드" 저장
  // -------------------------------------------------
  Future<void> _saveLargeTextSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLargeText', value);
  }

  /// PageView 컨트롤러 (대학 추천 슬라이드)
  late PageController _pageController;

  /// 자동 슬라이드 타이머
  Timer? _autoSlideTimer;

  /// 현재 페이지 인덱스
  int _currentPage = 0;

  /// 대학 정보 리스트
  List<Map<String, String>> _collegeList = [];

  @override
  void initState() {
    super.initState();
    // 큰 글자 설정 먼저 로드
    _loadLargeTextSetting();
    // 페이지 컨트롤러 초기화
    _pageController = PageController();
    // 서버에서 대학 데이터 불러오기
    _fetchCollegeData();
    // 자동 슬라이드 시작
    _startAutoSlide();
  }

  @override
  void dispose() {
    // 자동 슬라이드 타이머 정리
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  /// 서버에서 데이터 불러오는 함수
  Future<void> _fetchCollegeData() async {
    try {
      final response = await ApiService.searchCollege(page: 0);
      final allItems = response.result.result; // List<LikeUnivItem>

      if (allItems.isEmpty) {
        print('No colleges found');
        return;
      }

      // 랜덤으로 4개만 추출
      final random = Random();
      final temp = [...allItems];
      final chosen = <LikeUnivItem>[];

      for (int i = 0; i < 4 && temp.isNotEmpty; i++) {
        final idx = random.nextInt(temp.length);
        chosen.add(temp.removeAt(idx));
      }

      // UI에서 쓰기 편하도록 맵핑
      final mapped = chosen.map((item) {
        return {
          'collegeName': item.name,
          'subjectName':
          item.program.isNotEmpty ? item.program.join(', ') : '정보 없음',
          'phone': item.contactInfo,
          'email': item.headmaster,
          'website': item.address,
        };
      }).toList();

      setState(() {
        _collegeList = mapped;
      });
    } catch (e) {
      print('Error fetching colleges: $e');
    }
  }

  /// 5초 간격으로 자동 슬라이드 시작
  void _startAutoSlide() {
    _stopAutoSlide(); // 혹시 기존 타이머가 있으면 먼저 정지
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _goToNextPage();
    });
  }

  /// 자동 슬라이드 정지
  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  /// 다음 페이지로 이동
  void _goToNextPage() {
    if (_collegeList.isEmpty) return;
    final nextPage = (_currentPage + 1) % _collegeList.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  /// 뒤로 가기
  void _goBack() {
    Navigator.pop(context);
  }

  /// URL 실행
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  /// 큰 글자 모드에서 버튼 폰트 크기
  double get _buttonFontSize => _isLargeText ? 36 : 30;

  /// 화면 이동
  void _navigateTo(BuildContext context, Widget screen) {
    // 버튼 클릭 시 진동
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// 카드 내부 내용만 (대학 정보)
  Widget _buildCollegeContent(Map<String, String> info) {
    final double labelSize = _isLargeText ? 26 : 20;
    final double contentSize = _isLargeText ? 22 : 18;

    Widget infoRow(
        IconData icon,
        String label,
        String content, {
          VoidCallback? onTap,
        }) {
      final labelWidget = AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 250),
        style: TextStyle(
          fontSize: labelSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        child: Text(label),
      );

      final contentWidget = AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 250),
        style: TextStyle(
          fontSize: contentSize,
          color: onTap != null ? Colors.blue : Colors.black87,
          decoration:
          onTap != null ? TextDecoration.underline : TextDecoration.none,
        ),
        child: InkWell(
          onTap: onTap != null
              ? () {
            HapticFeedback.lightImpact(); // 버튼 클릭 시 진동
            onTap();
          }
              : null,
          child: Text(content),
        ),
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: labelSize + 4, color: Colors.grey[700]),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelWidget,
                  const SizedBox(height: 4),
                  contentWidget,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: _isLargeText ? 34 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            child: const Text("추천 대학", textAlign: TextAlign.center),
          ),
          const SizedBox(height: 10),
          // 나머지는 상단 정렬(좌측)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: infoRow(
                      Icons.school,
                      "대학명",
                      info['collegeName'] ?? '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoRow(
                      Icons.book,
                      "학부명",
                      info['subjectName'] ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: infoRow(
                      Icons.phone,
                      "전화",
                      info['phone'] ?? '',
                      onTap: () async {
                        final Uri telUri = Uri(
                          scheme: 'tel',
                          path: info['phone'] ?? '',
                        );
                        await _launchUrl(telUri);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoRow(
                      Icons.email,
                      "이메일",
                      info['email'] ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              infoRow(
                Icons.link,
                "사이트",
                info['website'] ?? '',
                onTap: () async {
                  final String website = info['website'] ?? '';
                  final Uri websiteUri = Uri.parse(
                    website.startsWith('http') ? website : 'https://$website',
                  );
                  await _launchUrl(websiteUri);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 뉴모피즘 버튼
  Widget _buildNeumorphicButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(6, 6),
              blurRadius: 20,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.95),
              offset: const Offset(-6, -6),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: _buttonFontSize + 16,
                color: Colors.black87,
              ),
              const SizedBox(height: 16),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: _buttonFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -----------------------
      // 두 번째 코드와 같은 구조의 AppBar(상단 영역) + 배경 그라데이션
      // -----------------------
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3E5ED),
              Color(0xFFDADCE2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // -----------------------
              // 1) 상단: "큰 글자" 스위치 (MobileAlertScreen과 동일 로직)
              // -----------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: _isLargeText ? 28 : 23,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    child: const Text('큰 글자'),
                  ),
                  const SizedBox(width: 3),
                  Switch(
                    value: _isLargeText,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isLargeText = value;
                      });
                      // 바뀐 값을 캐시에 저장
                      _saveLargeTextSetting(value);
                    },
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.blueAccent,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 10),

              // -----------------------
              // 2) 나머지 메인 컨텐츠 (SingleChildScrollView)
              // -----------------------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    children: [
                      // 추천 대학 뉴모피즘 컨테이너
                      // (PageView로 자동 슬라이드)
                      NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollStartNotification) {
                            _stopAutoSlide();
                          } else if (notification is ScrollEndNotification) {
                            _startAutoSlide();
                          }
                          return false;
                        },
                        child: Container(
                          constraints: BoxConstraints(minHeight: _isLargeText ? 250 : 200, maxHeight: _isLargeText ? 420 : 350),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: const Color(0xFFF0F0F3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: const Offset(6, 6),
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: const Offset(-6, -6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _collegeList.isEmpty
                                ? const Center(
                              child: Text(
                                "불러오는 중...",
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                                : PageView.builder(
                              controller: _pageController,
                              physics: const PageScrollPhysics(),
                              itemCount: _collegeList.length,
                              onPageChanged: (index) {
                                _currentPage = index;
                              },
                              itemBuilder: (context, index) {
                                final info = _collegeList[index];
                                return _buildCollegeContent(info);
                              },
                            ),
                          ),
                        ),
                      ),

                      // 2 x 2 버튼 (뉴모피즘)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.85,
                        children: [
                          _buildNeumorphicButton(
                            text: '대학\n이름 찾기',
                            icon: Icons.school,
                            color: const Color(0xFFFFC8D0),
                            onTap: () => _navigateTo(context, const SearchUniv()),
                          ),
                          _buildNeumorphicButton(
                            text: '과목\n이름 찾기',
                            icon: Icons.menu_book,
                            color: const Color(0xFFFFF5B3),
                            onTap: () =>
                                _navigateTo(context, const SearchSubject()),
                          ),
                          _buildNeumorphicButton(
                            text: '위치로\n찾기',
                            icon: Icons.location_on,
                            color: const Color(0xFFB7FFBF),
                            onTap: () => _navigateTo(context, const SearchGPS()),
                          ),
                          _buildNeumorphicButton(
                            text: '뒤로 가기',
                            icon: Icons.arrow_back,
                            color: const Color(0xFFB7EEFF),
                            onTap: _goBack,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
