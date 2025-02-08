import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bluedragonthon/screens/reminder.dart';
import 'package:bluedragonthon/screens/search_gps.dart';
import 'package:bluedragonthon/screens/search_subject.dart';
import 'package:bluedragonthon/screens/search_univ.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // <-- HapticFeedback을 사용하려면 추가

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  /// "큰 글자 모드" 여부
  bool _isLargeText = false;

  /// 사용자 슬라이드용 PageController (가로 이동)
  late PageController _pageController;

  /// 자동 슬라이드 기능을 위한 Timer
  Timer? _autoSlideTimer;

  /// 현재 페이지 인덱스
  int _currentPage = 0;

  /// 예시 데이터 (실제로는 fetchCollegeInfo() 결과를 받아올 수 있음)
  final List<Map<String, String>> _collegeList = [
    {
      'collegeName': '중앙대학교',
      'subjectName': '소프트웨어학부',
      'phone': '010-2797-1090',
      'email': 'sy020527@naver.com',
      'website': 'https://www.cau.ac.kr',
    },
    {
      'collegeName': '서울대학교',
      'subjectName': '컴퓨터공학부',
      'phone': '02-880-1234',
      'email': 'info@snu.ac.kr',
      'website': 'https://www.snu.ac.kr',
    },
    {
      'collegeName': '카이스트',
      'subjectName': '전산학부',
      'phone': '042-350-1234',
      'email': 'info@kaist.ac.kr',
      'website': 'https://www.kaist.ac.kr',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // 초기 자동 슬라이드 시작
    _startAutoSlide();
  }

  @override
  void dispose() {
    // Timer 해제
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  /// 5초 간격으로 자동 슬라이드 시작
  void _startAutoSlide() {
    // 먼저 타이머가 있다면 해제
    _stopAutoSlide();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // 다음 페이지로 이동
      _goToNextPage();
    });
  }

  /// 자동 슬라이드 정지
  void _stopAutoSlide() {
    if (_autoSlideTimer != null) {
      _autoSlideTimer!.cancel();
      _autoSlideTimer = null;
    }
  }

  /// 다음 페이지로 이동 (마지막 페이지에서 다시 첫 페이지로)
  void _goToNextPage() {
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

  /// URL 실행 (원본 코드 유지)
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

  /// 카드 내부 내용만 (대학 정보 표출)
  Widget _buildCollegeContent(Map<String, String> info) {
    final double labelSize = _isLargeText ? 26 : 20;
    final double contentSize = _isLargeText ? 22 : 18;

    Widget infoRow(IconData icon, String label, String content,
        {VoidCallback? onTap}) {
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
        // onTap 내부에서도 진동 발생
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // 타이틀 중앙
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
          // 나머지 항목은 상단 정렬(좌측)
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
                      // 여기는 onTap 없음
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
      // 버튼 클릭 시 진동
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
      body: Stack(
        children: [
          // 배경 그라데이션
          Container(
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
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // 오른쪽 상단 '큰 글자' 스위치
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
                          // 스위치 변경 시 진동
                          HapticFeedback.lightImpact();
                          setState(() {
                            _isLargeText = value;
                          });
                        },
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.blueAccent,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  // "외부" 뉴모피즘 컨테이너 (고정) + 내부 내용(PageView)만 이동
                  // 사용자가 드래그 시작/끝을 알기 위해 NotificationListener 사용
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      // 스크롤 시작하면 타이머 멈춤
                      if (notification is ScrollStartNotification) {
                        _stopAutoSlide();
                      }
                      // 스크롤 끝나면 타이머 재시작
                      else if (notification is ScrollEndNotification) {
                        _startAutoSlide();
                      }
                      return false;
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 200,
                        maxHeight: 350,
                      ),
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
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const PageScrollPhysics(),
                          itemCount: _collegeList.length,
                          onPageChanged: (index) {
                            // 현재 페이지 인덱스 업데이트
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
                  const SizedBox(height: 15),
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
                        onTap: () => _navigateTo(context, const SearchSubject()),
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
    );
  }
}
