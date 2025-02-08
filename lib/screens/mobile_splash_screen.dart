import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mobile_name_input_screen.dart'; // 아래 코드와 연결

class MobileSplashScreen extends StatefulWidget {
  const MobileSplashScreen({Key? key}) : super(key: key);

  @override
  State<MobileSplashScreen> createState() => _MobileSplashScreenState();
}

class _MobileSplashScreenState extends State<MobileSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserDataAfterDelay();
  }

  Future<void> _checkUserDataAfterDelay() async {
    // 실제 사용 시 3초 정도로 수정
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('userName');
    final int? age = prefs.getInt('userAge');
    final String? location = prefs.getString('userLocation');

    if (name != null && age != null && location != null) {
      // 이미 모든 데이터가 있다면 -> 메인 화면
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      // 하나라도 없다면 -> 이름 입력 화면 (애니메이션 전환)
      _navigateToNameInput();
    }
  }

  /// 배경 전환 + Hero 이동을 보여주는 커스텀 라우트
  void _navigateToNameInput() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(seconds: 2), // 애니메이션 시간
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MobileNameInputScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 0~1로 변하는 animation.value에 따라
          // 배경 색을 점차 흰색으로 보간
          final bgColor1 = Color.lerp(
            const Color(0xFFB3A3EC),
            Colors.white,
            animation.value,
          );
          final bgColor2 = Color.lerp(
            const Color(0xFFDAD4B6),
            Colors.white,
            animation.value,
          );

          return Stack(
            children: [
              // 배경 그라데이션이 점차 흰색으로
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgColor1!, bgColor2!],
                  ),
                ),
              ),
              // 다음 화면(child)도 서서히 나타나도록 FadeTransition
              FadeTransition(
                opacity: animation,
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Stack(
          children: [
            // (1) 기본 그라데이션 배경
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB3A3EC),
                    Color(0xFFDAD4B6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // (2) 중앙 텍스트
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    '원대',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900, // 더 두껍게
                      //fontStyle: FontStyle.italic,  // 기울임
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '여러분들의 원대한 교육 여정',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // (3) 오른쪽에 있는 원 (Hero 애니메이션 대상)
            Positioned(
              top: 0.075 * screenHeight,
              left: 0.3 * screenWidth,
              child: Hero(
                tag: 'transitionCircle', // 동일 태그로 NameScreen과 연결
                child: Container(
                  alignment: Alignment.bottomRight,
                  width: 1.5 * screenWidth,
                  height: 1.5 * screenHeight,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24, // 반투명 흰색
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
