import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mobile_name_input_screen.dart'; // 아래 코드와 연결

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
    // 실제 사용 시 3초 정도로 수정
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('userName');
    final int? age = prefs.getInt('userAge');
    final String? location = prefs.getString('userLocation');

    if (name != null && age != null && location != null) {
      // 이미 모든 데이터가 있다면 -> 메인 화면
      // 원래 여기에서 Navigator.pushReplacementNamed(context, '/main'); 였을 텐데,
      // 대신 새 애니메이션 메서드 호출
      _navigateToMain();
    } else {
      // 하나라도 없다면 -> 이름 입력 화면 (애니메이션 전환)
      _navigateToNameInput();
    }
  }

  /// (기존 코드) 배경 전환 + Hero 이동을 보여주는 커스텀 라우트
  /// 이 부분은 절대 수정하지 않음!
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

  /// (새로 추가) "스플래시 → 메인" 이동 시 적용할 애니메이션
  /// Hero + flightShuttleBuilder로 원이 왼쪽 상단으로 스윽 이동하면서
  /// 축소 & 페이드아웃 되도록 연출
  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(seconds: 2),
        pageBuilder: (context, animation, secondaryAnimation) {
          // '/main' 화면으로 네이밍된 실제 위젯
          // MaterialApp에서 '/main' 라우트가 MobileMainScreen()으로 연결되어 있다면,
          // 아래처럼 직접 Widget을 리턴해도 되고,
          // Navigator.pushReplacementNamed(context, '/main')를 대체해도 됩니다.
          return const _FakeMainScreen();
          // ↑ 예시용. 실제로는 MobileMainScreen()이 있으시면 거기로 교체하세요.
        },
        // Hero 애니메이션 + 새 커스텀 전환 효과
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              // 배경색 보간
              _buildBackground(animation),
              // 원(transitionCircle) 이동 애니메이션
              Positioned.fill(
                child: Hero(
                  tag: 'transitionCircle',
                  // Hero 효과를 커스터마이징
                  flightShuttleBuilder: (flightCtx, anim, flightDir,
                      fromHeroCtx, toHeroCtx) {
                    return _MovingCircleHero(animation: anim);
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              // 메인 화면 페이드 인
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

  // 배경색을 스플래시 배경( B3A3EC ~ DAD4B6 )에서
  // 하얀색에 가까운 더 밝은 톤으로 서서히 변경
  Widget _buildBackground(Animation<double> animation) {
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgColor1!, bgColor2!],
        ),
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
            Positioned(
              top: 0.075 * screenHeight,
              left: 0.3 * screenWidth,
              child: Hero(
                tag: 'transitionCircle', // 동일 태그로 NameScreen과 연결(유지)
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

/// Hero 애니메이션에서, 원이 왼쪽 상단으로 이동하며 축소 & 페이드아웃
class _MovingCircleHero extends StatelessWidget {
  final Animation<double> animation;
  const _MovingCircleHero({Key? key, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

    return AnimatedBuilder(
      animation: curved,
      builder: (ctx, child) {
        final progress = curved.value;
        // 0 ~ 1
        // 축소 비율 (1 -> 0)
        final scale = 1.0 - progress;
        // 투명도 (1 -> 0)
        final opacity = 1.0 - progress;
        // 왼쪽 상단으로 이동: progress=1일 때 화면 폭 * 0.5 정도 이동
        final dx = -MediaQuery.of(context).size.width * 0.5 * progress;
        final dy = -MediaQuery.of(context).size.height * 0.3 * progress;

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
        alignment: Alignment.center,
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

/// 실제 메인 화면 예시 ("/main" 라우트 대용)
class _FakeMainScreen extends StatelessWidget {
  const _FakeMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Main Screen Here',
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
