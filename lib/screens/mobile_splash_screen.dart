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
    // 실제 사용 시 3초 정도로 늘려도 됨
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

  /// 이름 입력 화면으로 이동
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

          // Hero 전환도 함께 적용되도록 기본적으로 Stack 안에 child가 들어있으면 됩니다.
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
              // FadeTransition + Hero
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

  /// 메인으로 이동 (Hero 전환 + 그라데이션 전환)
  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(seconds: 2),
        pageBuilder: (_, animation, __) => const MobileMainScreen(),
        transitionsBuilder: (_, animation, __, child) {
          // 스플래시 배경 -> 메인 배경 그라데이션 보간
          final bgColor1 = Color.lerp(
            const Color(0xFFB3A3EC),
            const Color(0xFFE3E5ED),
            animation.value,
          );
          final bgColor2 = Color.lerp(
            const Color(0xFFDAD4B6),
            const Color(0xFFDADCE2),
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
              // FadeTransition + Hero
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
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // (1) 그라데이션 배경
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
            // (3) 오른쪽 큰 원 (출발점) - Hero 적용
            Positioned(
              top: 0.075 * h,
              left: 0.3 * w,
              child: Hero(
                tag: 'transitionCircle',
                flightShuttleBuilder: (flightContext, animation, flightDirection,
                    fromHeroContext, toHeroContext) {
                  if (flightDirection == HeroFlightDirection.pop) {
                    return toHeroContext.widget;
                  } else {
                    final size = MediaQuery.of(flightContext).size;
                    final double w = size.width * 1.5;
                    final double h = size.height * 1.5;

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (_, __) {
                        final colorTween = ColorTween(
                          begin: Colors.white24,
                          end: Theme.of(flightContext).primaryColor,
                        );

                        return Container(
                          width: w,
                          height: h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorTween.evaluate(animation),
                          ),
                        );
                      },
                    );
                  }
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
