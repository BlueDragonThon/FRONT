import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 진동 피드백을 위해 필요
import 'package:shared_preferences/shared_preferences.dart';

// 이동할 스크린들 import (직접 사용하실 때 import 경로를 맞춰주세요)
import 'search.dart'; // 대학 찾기(첫 번째 버튼)
import 'reminder.dart'; // 알리미(두 번째 버튼)

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

  final List<Color> buttonColors = [
    const Color(0xFFFFC1CC),
    const Color(0xFFFFF4B2),
    const Color(0xFFB2FFC1),
    const Color(0xFFB2E6FF),
  ];

  // 버튼에 사용할 아이콘 (순서 동일하게)
  final List<IconData> buttonIcons = [
    Icons.search,         // 대학 찾기
    Icons.notifications,  // 알리미
    Icons.groups,         // 커뮤니티
    Icons.favorite,       // 나의 관심 대학
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // SharedPreferences에서 사용자 정보 로드
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
      userAge = prefs.getInt('userAge') ?? 0;
      userLocation = prefs.getString('userLocation') ?? '';
    });
  }

  // 정보 초기화 기능 (기존 기능 유지)
  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // 버튼 클릭 시 스크린 이동 로직
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // 버튼별로 동작을 분기
  void _onButtonTap(int index) {
    // 먼저 진동 피드백
    HapticFeedback.mediumImpact();

    switch (index) {
      case 0: // '대학 찾기'
        _navigateTo(context, const Search());
        break;
      case 1: // '알리미'
        _navigateTo(context, const CollegeReminderScreen());
        break;
      case 2: // '커뮤니티'
      // 기존 로직 유지 or 추가 화면
        break;
      case 3: // '나의 관심 대학'
      // 기존 로직 유지 or 추가 화면
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 글자 크기를 토글할 때 사용될 폰트 사이즈
    final double baseFontSize = _isLargeText ? 40.0 : 30.0;

    return Scaffold(
      // AppBar에 title을 없애고, 오른쪽에만 큰 글자 모드 스위치 표시
      appBar: AppBar(
        elevation: 0,
        title: null, // 메인화면 텍스트 제거
        centerTitle: false,
        actions: [
          Row(
            children: [
              Text(
                '큰 글자',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 3,),
              Switch(
                value: _isLargeText,
                onChanged: (value) {
                  setState(() {
                    _isLargeText = value;
                  });
                },
                // 토글이 항상 보이도록 트랙 색상 지정
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey,
                activeColor: Colors.white,
                activeTrackColor: Colors.blueAccent,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: SafeArea(
        // 내용이 많아질 경우 스크롤 가능하도록 변경
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18.0, 0, 18, 0),
          child: Column(
            children: [
              // 상단: 이름만 표시(있을 경우)
              if (userName != null && userName!.isNotEmpty)
                Text(
                  '$userName 님 안녕하세요!',
                  style: TextStyle(
                    fontSize: baseFontSize + 6,  // 이름은 좀 더 크게
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),

              // 버튼들을 2열 그리드로 배치
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                // childAspectRatio가 작을수록 세로로 길어짐
                // 더 크게 보이도록 0.7 ~ 0.8 정도로 설정
                childAspectRatio: 0.7,
                children: List.generate(buttonTexts.length, (index) {
                  return _SeniorFriendlyButton(
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
                    // 진동 피드백
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
            ],
          ),
        ),
      ),
    );
  }
}

/// 노인 친화적 버튼 스타일 위젯
class _SeniorFriendlyButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double fontSize;

  const _SeniorFriendlyButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    this.onTap,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 노인 친화적: 버튼 자체 크기를 크게 하고, 여백을 많이 줌
    return InkWell(
      onTap: () {
        // 버튼 눌렀을 때 진동 피드백
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: fontSize + 16, // 텍스트보다 더 크게
                color: Colors.black87,
              ),
              const SizedBox(height: 16),
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
