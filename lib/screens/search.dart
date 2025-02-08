import 'package:bluedragonthon/screens/reminder.dart';
import 'package:bluedragonthon/screens/search_gps.dart';
import 'package:bluedragonthon/screens/search_subject.dart';
import 'package:bluedragonthon/screens/search_univ.dart';
import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(top: 40, bottom: 20, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 236, 104, 95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _navigateTo(context, const CollegeReminderScreen()),
                child: const Text('대학 이름 찾기', style: TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.w700),),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 210, 97),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _navigateTo(context, const SearchSubject()),
                child: const Text('과목 이름으로 찾기', style: TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.w700),),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _navigateTo(context, const SearchGPS()),
                child: const Text('위치로 찾기', style: TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.w700),),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('뒤로 가기', style: TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.w700),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
