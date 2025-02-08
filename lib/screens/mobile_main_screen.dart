import 'package:bluedragonthon/screens/mobile_lecture_review.dart';
import 'package:bluedragonthon/screens/mobile_like_univ_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // --------------------
  // "큰 글자 모드" 여부
  // --------------------
  bool _isLargeText = false;

  // --------------------
  // 공유 함수: "큰 글자 모드" 로드
  // --------------------
  Future<void> _loadLargeTextSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLargeText = prefs.getBool('isLargeText') ?? false;
    });
  }

  // --------------------
  // 공유 함수: "큰 글자 모드" 저장
  // --------------------
  Future<void> _saveLargeTextSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLargeText', value);
  }

  // --------------------
  // 유저 정보 로드
  // --------------------
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
      userAge = prefs.getInt('userAge') ?? 0;
      userLocation = prefs.getString('userLocation') ?? '';
    });
  }

  // --------------------
  // 유저 데이터 초기화
  // --------------------
  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // --------------------
  // 화면 이동 함수
  // --------------------
  void _navigateTo(BuildContext context, Widget screen) async {
    // Navigator.push를 await 해 두면, 뒤로 돌아왔을 때 _isLargeText 갱신 가능
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    // 뒤로 돌아온 직후에 다시 로드하여, 다른 화면에서 바뀐 상태를 반영
    _loadLargeTextSetting();
  }

  // --------------------
  // 메인 버튼 탭했을 때
  // --------------------
  void _onButtonTap(int index) {
    HapticFeedback.mediumImpact();
    switch (index) {
      case 0:
        _navigateTo(context, const Search()); // <-- Search로 이동
        break;
      case 1:
        _navigateTo(context, const MobileAlertScreen());
        break;
      case 2:
        _navigateTo(context, const MobileLectureReviewScreen());
        break;
      case 3:
        _navigateTo(context, const MobileLikeUnivListScreen());
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLargeTextSetting(); // 큰 글자 모드 설정 불러오기
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
              // (2) Hero 공간(스플래시와의 연결용)
              Positioned(
                top: 0,
                left: 0,
                child: Hero(
                  tag: 'transitionCircle',
                  flightShuttleBuilder: (
                      flightContext,
                      animation,
                      flightDirection,
                      fromHeroContext,
                      toHeroContext,
                      ) {
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
                              // 스위치가 변경될 때 SharedPreferences에 즉시 저장
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

                      // 2 x 2 버튼 그리드
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.7,
                        children: List.generate(4, (index) {
                          // 버튼 정보
                          final List<String> buttonTexts = [
                            '대학 찾기',
                            '알리미',
                            '수강후기',
                            '나의\n관심 대학',
                          ];
                          final List<Color> buttonColors = [
                            const Color(0xFFFFC8D0),
                            const Color(0xFFFFF5B3),
                            const Color(0xFFB7FFBF),
                            const Color(0xFFB7EEFF),
                          ];
                          final List<IconData> buttonIcons = [
                            Icons.search,
                            Icons.notifications,
                            Icons.groups,
                            Icons.favorite,
                          ];

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
    required this.fontSize,
    this.onTap,
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
