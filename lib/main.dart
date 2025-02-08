import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/mobile_splash_screen.dart';
import 'screens/mobile_name_input_screen.dart';
import 'screens/mobile_age_select_screen.dart';
import 'screens/mobile_location_input_screen.dart';
import 'screens/mobile_main_screen.dart';

void main() async {
  // 플러그인(SharedPreferences 등) 사용 전 반드시 초기화
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFFB3A3EC);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOWUM',
      theme: ThemeData(
        fontFamily: 'Pretendard', // Pretendard 폰트 적용
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: primaryColor,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MobileSplashScreen(),
        //'/name': (context) => const MobileNameInputScreen(),
        '/age': (context) => const MobileAgeSelectScreen(),
        '/location': (context) => const MobileLocationInputScreen(),
        '/main': (context) => const MobileMainScreen(),
      },
    );
  }
}
