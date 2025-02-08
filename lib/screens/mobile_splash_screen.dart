import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mobile_name_input_screen.dart'; // 이름 입력 화면
import 'mobile_main_screen.dart';       // 메인 화면 (아래 예시와 연결)

class MobileSplashScreen extends StatefulWidget {
  const MobileSplashScreen({super.key});

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
    // 실제 사용 시 3초 정도로 조절
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('userName');
    final int? age = prefs.getInt('userAge');
    final String? location = prefs.getString('userLocation');

    if (name != null && age != null && location != null) {
      // 이미 모든 데이터가 있다면 -> 메인 화면
      _navigateToMain();
    } else {
      // 하나라도 없다면 -> 이름 입력 화면
      _navigateToNameInput();
    }
  }

  /// (1) 이름 입력 화면으로 이동
  void _navigateToNameInput() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(seconds: 2),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MobileNameInputScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 배경색을 점차 흰색으로 보간
          final bgColor1 = Color.lerp(
            const Color(0xFFB3A3EC), // 원래보다 조금 연한 보라색
            Colors.white,
            animation.value,
          );
          final bgColor2 = Color.lerp(
            const Color(0xFFDAD4B6), // 원래보다 조금 연한 베이지
            Colors.white,
            animation.value,
          );

          return Stack(
            children: [
              // (1) 배경 그라데이션
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgColor1!, bgColor2!],
                  ),
                ),
              ),
              // (2) 다음 화면(child) 서서히 나타나도록
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

  /// (2) 메인 화면으로 이동 (스플래시 원이 왼쪽 상단 방향으로 이동 + 축소/페이드)
  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(seconds: 2),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MobileMainScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 배경색을 점차 흰색으로 보간
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
              // (1) 배경 그라데이션
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgColor1!, bgColor2!],
                  ),
                ),
              ),
              // (2) 메인 화면(child)을 서서히 나타나게
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
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '여러분의 원대한 교육 여정',
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
            //     => 여기서 flightShuttleBuilder로 직접 좌측 상단 이동 + 축소/페이드
            Positioned(
              top: 0.075 * screenHeight,
              left: 0.3 * screenWidth,
              child: Hero(
                tag: 'transitionCircle',
                // Hero 애니메이션 커스터마이징:
                flightShuttleBuilder: (flightContext, animation, flightDirection,
                    fromHeroContext, toHeroContext) {
                  return _MovingCircleHero(animation: animation);
                },
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

/// 원이 왼쪽 상단으로 스윽 이동 + 점차 축소 + 페이드 아웃
class _MovingCircleHero extends StatelessWidget {
  final Animation<double> animation;
  const _MovingCircleHero({Key? key, required this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 가속 곡선
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

    return AnimatedBuilder(
      animation: curved,
      builder: (ctx, child) {
        // 0 ~ 1
        final progress = curved.value;
        // 크기는 1 ~ 0으로 줄어듦
        final scale = 1.0 - progress;
        // 투명도도 1 ~ 0
        final opacity = 1.0 - progress;

        // 왼쪽 상단으로 이동하려면 음수 offset
        // progress = 1일 때 대략 0.5 * 화면 가로만큼 이동
        final dx = -0.5 * MediaQuery.of(context).size.width * progress;
        // progress = 1일 때 대략 0.5 * 화면 세로만큼 위로 이동
        final dy = -0.5 * MediaQuery.of(context).size.height * progress;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  // 원시 컨테이너
  Widget get child => Container(
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white24,
    ),
  );
}
