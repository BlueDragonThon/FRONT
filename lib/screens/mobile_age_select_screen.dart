import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mobile_name_input_screen.dart';
import 'mobile_location_input_screen.dart';

class MobileAgeSelectScreen extends StatefulWidget {
  const MobileAgeSelectScreen({Key? key}) : super(key: key);

  @override
  State<MobileAgeSelectScreen> createState() => _MobileAgeSelectScreenState();
}

class _MobileAgeSelectScreenState extends State<MobileAgeSelectScreen> {
  final List<int> _ageList = List.generate(51, (index) => 50 + index);
  late FixedExtentScrollController _scrollController;

  /// 아직 로드 전이면 null일 수 있으므로, 초깃값은 null
  /// 로드 실패나 없으면 65로 세팅
  int? _selectedAge;

  @override
  void initState() {
    super.initState();
    // 스크롤 컨트롤러 초기화
    _scrollController = FixedExtentScrollController();
    _loadSavedAge();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// SharedPreferences에서 저장된 나이를 불러와 _selectedAge에 세팅
  /// 그리고 CupertinoPicker도 해당 인덱스로 jump
  Future<void> _loadSavedAge() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAge = prefs.getInt('userAge') ?? 65; // 없으면 65
    setState(() {
      _selectedAge = savedAge;
    });
    // picker 위치 이동
    final index = _ageList.indexOf(savedAge);
    if (index >= 0) {
      // initState 시점이므로 jumpToItem 사용 가능
      _scrollController.jumpToItem(index);
    }
  }

  /// 나이를 SharedPreferences에 저장
  Future<void> _saveAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userAge', age);
  }

  /// 위치 페이지로 (Fade + Hero)
  void _goToLocationScreen() {
    // push로 넘어가야 뒤로가기(pop) 가능
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const MobileLocationInputScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// "다음" 버튼
  void _onNext() async {
    // 진동
    HapticFeedback.lightImpact();

    if (_selectedAge == null) {
      // 아직 로딩 안 됐거나 예외적인 경우
      setState(() => _selectedAge = 65);
    }

    await _saveAge(_selectedAge!);
    _goToLocationScreen();
  }

  /// 뒤로가기 → 이름 입력 화면
  void _goBack() {
    // 진동
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    // pop() 시, 이전 화면(이름)으로 Fade reverse
  }

  @override
  Widget build(BuildContext context) {
    final displayedAge = _selectedAge ?? 65; // 로드 전이면 임시로 65 표시

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // (1) 메인 콘텐츠
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '나이를 선택해주세요',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CupertinoPicker
                    SizedBox(
                      height: 200,
                      child: CupertinoPicker(
                        scrollController: _scrollController,
                        itemExtent: 48,
                        onSelectedItemChanged: (index) {
                          // 다이얼 돌릴 때 진동
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedAge = _ageList[index];
                          });
                        },
                        children: _ageList.map((age) {
                          return Center(
                            child: Text(
                              '$age',
                              style: const TextStyle(fontSize: 30),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      '선택한 나이 : $displayedAge',
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(height: 32),

                    // 다음 버튼 (Hero)
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

            // (2) 왼쪽 상단 뒤로가기 버튼
            Positioned(
              top: 5,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 50),
                color: Colors.black,
                onPressed: _goBack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
