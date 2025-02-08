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

  // 만약 재설정(로그아웃 등) 기능이 필요하면 예시와 같이 구현 가능
  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 모든 데이터 삭제
    // 이후 다시 앱 시작 플로우를 재진행하고 싶다면:
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar는 사용하지 않음
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '메인 화면',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                if (userName != null && userAge != null && userLocation != null)
                  Text(
                    '$userName 님, 안녕하세요!\n'
                        '나이: $userAge\n'
                        '지역: $userLocation',
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _resetData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(200, 60),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('데이터 초기화'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
