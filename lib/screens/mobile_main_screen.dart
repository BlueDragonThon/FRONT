import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileMainScreen extends StatefulWidget {
  const MobileMainScreen({Key? key}) : super(key: key);

  @override
  State<MobileMainScreen> createState() => _MobileMainScreenState();
}

class _MobileMainScreenState extends State<MobileMainScreen> {
  String? userName;
  int? userAge;
  String? userLocation;

  // 4개 항목 버튼 텍스트와 색상
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar가 필요 없다면 삭제 가능
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 메인 화면 제목: 글자 크기 확대
              Text(
                '메인 화면',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // 사용자 정보: 글자 크기 확대
              if (userName != null && userAge != null && userLocation != null)
                Text(
                  '$userName 님, 안녕하세요!\n나이: $userAge\n지역: $userLocation',
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              // 2열 그리드로 4개 버튼 배치
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: List.generate(buttonTexts.length, (index) {
                  return ModernButtonWidget(
                    text: buttonTexts[index],
                    color: buttonColors[index],
                    height: 120,
                  );
                }),
              ),
              const Spacer(),
              // 하단의 정보 초기화 버튼 (기능 그대로 유지)
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton(
                  onPressed: _resetData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('정보 초기화'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 버튼 스타일 위젯 (동작은 미구현)
class ModernButtonWidget extends StatelessWidget {
  final String text;
  final Color color;
  final double height;

  const ModernButtonWidget({
    Key? key,
    required this.text,
    required this.color,
    this.height = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 그림자와 그라데이션을 제거하고, 단색 배경 + 테두리만 간단히 적용
    return InkWell(
      onTap: () {}, // 버튼 동작 미구현
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
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
              color: Colors.black, // 가독성을 위해 검정색
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
