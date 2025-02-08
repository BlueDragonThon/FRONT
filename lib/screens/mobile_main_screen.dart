import 'package:bluedragonthon/screens/likes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 나머지 import
import 'search.dart';
import 'reminder.dart';
import 'mobile_alart_screen.dart';

class MobileMainScreen extends StatefulWidget {
  const MobileMainScreen({super.key});

  @override
  State<MobileMainScreen> createState() => _MobileMainScreenState();
}

class _MobileMainScreenState extends State<MobileMainScreen> {
  String? userName;
  int? userAge;
  String? userLocation;
  bool _isLargeText = false;

  final List<String> buttonTexts = [
    '대학 찾기',
    '알리미',
    '커뮤니티',
    '나의\n관심 대학',
  ];

  final List<Color> buttonColors = [
    Color(0xFFFFC8D0),
    Color(0xFFFFF5B3),
    Color(0xFFB7FFBF),
    Color(0xFFB7EEFF),
  ];

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
      case 0:
      // Search 화면
        _navigateTo(context, const Search());
        break;
      case 1:
        _navigateTo(context, const MobileAlertScreen());
        break;
      case 2:
      // 커뮤니티
        break;
      case 3:
    }
  }

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = _isLargeText ? 40.0 : 30.0;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            children: [
              // (1) 배경 그라데이션
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE3E5ED), Color(0xFFDADCE2)],
                  ),
                ),
              ),
              // (2) 좌측 상단에 Hero로 연결될 작은 원(혹은 0 크기)
              //     스플래시의 커다란 원이 여기로 날아와서 사라지는 느낌
              Positioned(
                top: 0,
                left: 0,
                child: Hero(
                  tag: 'transitionCircle',
                  flightShuttleBuilder: (flightContext, animation, flightDirection,
                      fromHeroContext, toHeroContext) {
                    if (flightDirection == HeroFlightDirection.push) {
                      return fromHeroContext.widget;
                    } else {
                      return toHeroContext.widget;
                    }
                  },
                  child: Container(
                    width: 0,
                    height: 0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
              // (3) 메인 UI
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
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

                      // 2x2 버튼 그리드
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

/// 뉴모피즘 버튼 예시
class _NeumorphicButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double fontSize;

  const _NeumorphicButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.onTap,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
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
