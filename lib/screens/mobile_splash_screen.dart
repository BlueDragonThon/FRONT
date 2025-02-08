import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// "이름 입력 화면" - 절대 수정 X
import 'mobile_name_input_screen.dart';

// "메인 화면"
import 'mobile_main_screen.dart';

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
    // 실제 사용 시 3초 정도
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('userName');
    final int? age = prefs.getInt('userAge');
    final String? location = prefs.getString('userLocation');

    if (name != null && age != null && location != null) {
      _navigateToMain();
    } else {
      _navigateToNameInput(); // 절대 수정 X
    }
  }

  /// (기존) 이름 설정
  void _navigateToNameInput() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(seconds: 2),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MobileNameInputScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgColor1!, bgColor2!],
                  ),
                ),
              ),
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

  /// 메인으로 이동 (Hero 애니메이션)
  void _navigateToMain() {
    // routes: {'/main': (ctx) => MobileMainScreen()} 라고 등록되어 있으면
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // (1) 그라데이션
            Container(
              width: w,
              height: h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB3A3EC), Color(0xFFDAD4B6)],
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
            // (3) Hero: 오른쪽 큰 원 (출발)
            Positioned(
              top: 0.075 * h,
              left: 0.3 * w,
              child: Hero(
                tag: 'transitionCircle',
                flightShuttleBuilder: (flightCtx, anim, dir, fromCtx, toCtx) {
                  return _MovingCircleHero(animation: anim);
                },
                child: Container(
                  alignment: Alignment.bottomRight,
                  width: 1.5 * w,
                  height: 1.5 * h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
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

/// 원 이동 + 축소 + 페이드
class _MovingCircleHero extends StatelessWidget {
  final Animation<double> animation;
  const _MovingCircleHero({Key? key, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (ctx, child) {
        final p = curved.value;
        final scale = 1.0 - p;
        final opacity = 1.0 - p;
        final dx = -0.5 * MediaQuery.of(context).size.width * p;
        final dy = -0.3 * MediaQuery.of(context).size.height * p;

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
      child: Container(
        width: MediaQuery.of(context).size.width * 1.5,
        height: MediaQuery.of(context).size.height * 1.5,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
        ),
      ),
    );
  }
}
