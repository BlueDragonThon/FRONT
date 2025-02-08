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
      // Search 화면 (Hero 삭제됨)
        _navigateTo(context, const Search());
        break;
      case 1:
        _navigateTo(context, const MobileAlertScreen());
        break;
      case 2:
        break;
      case 3:
        break;
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
              // (2) Hero 도착 지점 (왼쪽 상단, 작게)
              Positioned(
                top: 60,
                left: 20,
                child: Hero(
                  tag: 'transitionCircle',
                  // flightShuttleBuilder 없음
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
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

/// (기존) 뉴모피즘 + 그림자 강조
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
