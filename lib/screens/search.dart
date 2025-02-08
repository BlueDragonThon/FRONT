import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bluedragonthon/screens/reminder.dart';
import 'package:bluedragonthon/screens/search_gps.dart';
import 'package:bluedragonthon/screens/search_subject.dart';
import 'package:bluedragonthon/screens/search_univ.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  // 화면 간 이동을 위한 함수
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // 실제 API에서 정보를 받아오는 함수 (API 엔드포인트를 실제 값으로 변경하세요)
  // Future<Map<String, dynamic>> fetchCollegeInfo() async {
  //   final String url = 'https://api.example.com/collegeinfo';
  //   final response = await http.get(Uri.parse(url));
  //
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body) as Map<String, dynamic>;
  //   } else {
  //     throw Exception('Failed to load college info: ${response.statusCode}');
  //   }
  // }

  // 주어진 URL을 실행하는 함수
  Future<void> _launchUrl(Uri url) async {
    // 보통 main()에서 WidgetsFlutterBinding.ensureInitialized()를 호출합니다.
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _infoRow(IconData icon, String label, String content,
      {VoidCallback? onTap}) {
    final Widget contentWidget = onTap != null
        ? InkWell(
            onTap: onTap,
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        : Text(
            content,
            style: const TextStyle(fontSize: 20, color: Colors.black87),
          );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 4),
            contentWidget,
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(top: 30, bottom: 20, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 백엔드 API에서 받아온 데이터를 표시하는 FutureBuilder 예시 (현재는 주석 처리)
            // FutureBuilder<Map<String, dynamic>>(
            //   future: fetchCollegeInfo(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(child: CircularProgressIndicator());
            //     } else if (snapshot.hasError) {
            //       return Text('Error: ${snapshot.error}');
            //     } else if (snapshot.hasData) {
            //       final info = snapshot.data!;
            //       return Card(
            //         margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //         shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(20)),
            //         elevation: 8,
            //         child: Padding(
            //           padding: const EdgeInsets.all(20),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            // Container(
            //   decoration: BoxDecoration(
            //       color: Color.fromARGB(255, 179, 163, 236),
            //       borderRadius: BorderRadius.all(
            //         Radius.circular(15.0),
            //       )),
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            //     child: Text(
            //       "추천 대학",
            //       style: TextStyle(
            //         fontSize: 30,
            //         fontWeight: FontWeight.w800,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(
            //   height: 10,
            // ),
            //               Row(
            //                 children: [
            //                   _infoRow(Icons.school, "대학명", info['collegeName']),
            //                   const SizedBox(width: 20),
            //                   _infoRow(Icons.book, "과목명", info['subjectName']),
            //                 ],
            //               ),
            //               const SizedBox(height: 20),
            //               _infoRow(
            //                 Icons.phone,
            //                 "전화번호",
            //                 info['phone'],
            //                 onTap: () async {
            //                   final Uri telUri = Uri(scheme: 'tel', path: info['phone']);
            //                   await _launchUrl(telUri);
            //                 },
            //               ),
            //               const SizedBox(height: 20),
            //               _infoRow(Icons.email, "이메일", info['email']),
            //               const SizedBox(height: 20),
            //               _infoRow(
            //                 Icons.link,
            //                 "사이트 주소",
            //                 info['website'],
            //                 onTap: () async {
            //                   final Uri websiteUri = Uri.parse(
            //                     info['website'].startsWith('http')
            //                         ? info['website']
            //                         : 'https://${info['website']}',
            //                   );
            //                   await _launchUrl(websiteUri);
            //                 },
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     }
            //     return const SizedBox.shrink();
            //   },
            // ),

            // 더미 데이터를 이용한 정보 카드 (고급스럽고 어르신들이 사용하기 편한 디자인)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 179, 163, 236),
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.0),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 5),
                        child: Text(
                          "추천 대학",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        _infoRow(Icons.school, "대학명", "중앙대학교"),
                        const SizedBox(width: 20),
                        _infoRow(Icons.book, "과목명", "소프트웨어학부"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _infoRow(
                      Icons.phone,
                      "전화번호",
                      "010-2797-1090",
                      onTap: () async {
                        final Uri telUri =
                            Uri(scheme: 'tel', path: "01027971090");
                        await _launchUrl(telUri);
                      },
                    ),
                    const SizedBox(height: 20),
                    _infoRow(Icons.email, "이메일", "sy020527@naver.com"),
                    const SizedBox(height: 20),
                    _infoRow(
                      Icons.link,
                      "사이트 주소",
                      "https://www.cau.ac.kr",
                      onTap: () async {
                        final String website = "www.cau.ac.kr";
                        final Uri websiteUri = Uri.parse(
                            website.startsWith('http')
                                ? website
                                : 'https://www.cau.ac.kr');
                        await _launchUrl(websiteUri);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 버튼 영역: Expanded 위젯으로 세로 전체를 균등하게 채움
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 236, 104, 95),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () =>
                    _navigateTo(context, const SearchUniv()),
                child: const Text(
                  '대학 이름 찾기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 210, 97),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _navigateTo(context, const SearchSubject()),
                child: const Text(
                  '과목 이름으로 찾기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _navigateTo(context, const SearchGPS()),
                child: const Text(
                  '위치로 찾기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '뒤로 가기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
