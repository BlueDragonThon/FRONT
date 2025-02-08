import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 이동할 스크린들 import (직접 사용하실 때 import 경로를 맞춰주세요)
import 'search.dart'; // 대학 찾기(첫 번째 버튼)
import 'reminder.dart'; // 알리미(두 번째 버튼)
// 나머지 두 버튼(커뮤니티, 나의 관심 대학)은 기존대로 유지한다면 별도 이동 코드/화면이 없거나 기존과 동일

class MobileMainScreen extends StatefulWidget {
  const MobileMainScreen({Key? key}) : super(key: key);

  @override
  State<MobileMainScreen> createState() => _MobileMainScreenState();
}

class _MobileMainScreenState extends State<MobileMainScreen> {
  String? userName;
  int? userAge;         // 더 이상 표시하지 않음
  String? userLocation; // 더 이상 표시하지 않음

  // 4개 항목 버튼 텍스트와 색상 (순서 유지)
  final List<String> buttonTexts = [
    '대학 찾기',
    '알리미',
    '커뮤니티',
    '나의 관심 대학',
  ];

  final List<Color> buttonColors = [
    const Color(0xFFFFC1CC),
    const Color(0xFFFFF4B2),
    const Color(0xFFB2FFC1),
    const Color(0xFFB2E6FF),
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

  // 버튼 클릭 시 스크린 이동 로직 (필요에 따라 추가/수정)
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // 버튼별로 동작을 분기하기 위해 함수 생성 (필요하다면)
  void _onButtonTap(int index) {
    switch (index) {
      case 0: // '대학 찾기'
        _navigateTo(context, const Search());
        break;
      case 1: // '알리미'
        _navigateTo(context, const CollegeReminderScreen());
        break;
      case 2: // '커뮤니티'
      // 기존 로직을 유지하거나 원하는 화면으로 이동
        break;
      case 3: // '나의 관심 대학'
      // 기존 로직을 유지하거나 원하는 화면으로 이동
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // 내용이 많아질 경우 스크롤 가능하도록 변경
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 상단: 이름만 표시
              if (userName != null && userName!.isNotEmpty)
                Text(
                  '$userName 님 안녕하세요!',
                  style: const TextStyle(
                    fontSize: 30,
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
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: List.generate(buttonTexts.length, (index) {
                  return _ModernButtonWidget(
                    text: buttonTexts[index],
                    color: buttonColors[index],
                    onTap: () => _onButtonTap(index),
                  );
                }),
              ),
              const SizedBox(height: 40),
              // 정보 초기화 버튼
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton(
                  onPressed: _resetData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 버튼 텍스트 흰색
                    ),
                  ),
                  child: const Text(
                    '정보 초기화',
                    style: TextStyle(color: Colors.white), // 추가로 명시
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

/// 버튼 스타일 위젯
class _ModernButtonWidget extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onTap;

  const _ModernButtonWidget({
    Key? key,
    required this.text,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 그림자, 그라데이션 제거 + 단색 배경
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black, // 파스텔톤 배경 대비 검정색 텍스트
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
