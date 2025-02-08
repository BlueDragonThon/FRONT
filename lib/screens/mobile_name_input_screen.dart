import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mobile_age_select_screen.dart'; // 나이 화면

class MobileNameInputScreen extends StatefulWidget {
  const MobileNameInputScreen({Key? key}) : super(key: key);

  @override
  State<MobileNameInputScreen> createState() => _MobileNameInputScreenState();
}

class _MobileNameInputScreenState extends State<MobileNameInputScreen> {
  final TextEditingController _nameController = TextEditingController();

  // 이미 입력된 이름 불러오기
  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userName') ?? '';
    _nameController.text = savedName;
  }

  // 이름 저장
  Future<void> _saveName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text.trim());
  }

  void _onNext() async {
    if (_nameController.text.trim().isEmpty) {
      // 진동(오류 느낌)
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요.')),
      );
      return;
    }
    // 정상 입력 -> 가벼운 진동
    HapticFeedback.lightImpact();

    await _saveName();

    // 이름 입력 → 나이 선택 (Push + FadeTransition)
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => const MobileAgeSelectScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경 흰색
      backgroundColor: Colors.white,
      body: GestureDetector(
        // 바깥쪽 터치하면 키보드 닫기
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '이름을 입력해주세요',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),

                // TextField
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 25),
                  decoration: InputDecoration(
                    hintText: '예) 홍길동',
                    hintStyle: const TextStyle(
                      color: Colors.black54,
                      fontSize: 25,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Hero로 연결된 원형 버튼 (절대 수정 X)
                Hero(
                  tag: 'transitionCircle',
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Theme.of(context).primaryColor,
                        elevation: 0,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
