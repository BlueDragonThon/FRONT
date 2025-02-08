import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 이동할 스크린들 import
import 'search.dart';
import 'reminder.dart';

class MobileMainScreen extends StatefulWidget {
  const MobileMainScreen({Key? key}) : super(key: key);

  @override
  State<MobileMainScreen> createState() => _MobileMainScreenState();
}

class _MobileMainScreenState extends State<MobileMainScreen> {
  String? userName;
  int? userAge;         // 더 이상 표시하지 않음
  String? userLocation; // 더 이상 표시하지 않음

  // '큰 글자 모드' 여부
  bool _isLargeText = false;

  // 4개 항목 버튼 텍스트와 색상 (순서 유지)
  final List<String> buttonTexts = [
    '대학 찾기',
    '알리미',
    '커뮤니티',
    '나의\n관심 대학',
  ];

  // "조금 더 진한" 파스텔 톤
  final List<Color> buttonColors = [
    const Color(0xFFFFC8D0), // 기존보다 살짝 더 진한 핑크
    const Color(0xFFFFF5B3), // 노랑
    const Color(0xFFB7FFBF), // 그린
    const Color(0xFFB7EEFF), // 블루
  ];

  // 버튼 아이콘
  final List<IconData> buttonIcons = [
    Icons.search,
    Icons.notifications,
    Icons.groups,
    Icons.favorite,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
      userAge = prefs.getInt('userAge') ?? 0;
      userLocation = prefs.getString('userLocation') ?? '';
    });
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _onButtonTap(int index) {
    HapticFeedback.mediumImpact();
    switch (index) {
      case 0: // 대학 찾기
        _navigateTo(context, const Search());
        break;
      case 1: // 알리미
        _navigateTo(context, const CollegeReminderScreen());
        break;
      case 2: // 커뮤니티
        break;
      case 3: // 나의 관심 대학
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 큰 글자 모드에 따라 폰트 크기 달라짐
    final double baseFontSize = _isLargeText ? 40.0 : 30.0;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // 배경 그라데이션 (이전보다 조금 더 진한 느낌)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE3E5ED), // 연한 회색
                      Color(0xFFDADCE2), // 조금 더 진한 회색
                    ],
                  ),
                ),
              ),
              // 스플래시 원(Hero)와 연결된 부분
              Positioned(
                top: -0.4 * screenHeight,
                left: -0.1 * screenWidth, // 왼쪽 바깥
                child: Hero(
                  tag: 'transitionCircle',
                  child: Container(
                    width: 1.6 * screenWidth,
                    height: 1.6 * screenHeight,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // 상단: '큰 글자' 스위치
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
                      const SizedBox(height: 20),

                      // 사용자 이름
                      if (userName != null && userName!.isNotEmpty)
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: baseFontSize + 6,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          child: Text(
                            '$userName 님 안녕하세요!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 24),

                      // 2 x 2 버튼
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.7,
                        children: List.generate(buttonTexts.length, (index) {
                          return _NeumorphicButton(
                            text: buttonTexts[index],
                            icon: buttonIcons[index],
                            color: buttonColors[index],
                            fontSize: baseFontSize,
                            onTap: () => _onButtonTap(index),
                          );
                        }),
                      ),
                      const SizedBox(height: 40),

                      // 정보 초기화 버튼
                      SizedBox(
                        width: 320,
                        height: 80,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            _resetData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            textStyle: TextStyle(
                              fontSize: baseFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          child: const Text(
                            '정보 초기화',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 뉴모피즘 + 그림자 강조
class _NeumorphicButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double fontSize;

  const _NeumorphicButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    this.onTap,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 큰 글자 변환 애니메이션을 위해 AnimatedDefaultTextStyle 사용
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          // 그림자 더 강조
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(6, 6),
              blurRadius: 20,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.99),
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
                size: fontSize + 16,
                color: Colors.black87,
              ),
              const SizedBox(height: 16),
              // 텍스트가 커졌다 작아지도록 AnimatedDefaultTextStyle
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: fontSize,
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
}
