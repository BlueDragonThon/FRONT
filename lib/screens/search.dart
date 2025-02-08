import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bluedragonthon/screens/reminder.dart';
import 'package:bluedragonthon/screens/search_gps.dart';
import 'package:bluedragonthon/screens/search_subject.dart';
import 'package:bluedragonthon/screens/search_univ.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/*
================================================================================
====================== [ 원본 코드 (주석 포함) - 절대 수정 금지 ] ===============
================================================================================

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

            // 뒤로 가기 버튼 -> (원본 코드에 있던 '알리미' 대신)
            // ------------------------
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

================================================================================
====================== [ 원본 코드 (주석 포함) - 절대 수정 금지 ] ===============
================================================================================
*/

/*
================================================================================
====================== [ 새로운 변경 UI 적용된 Search ] =========================
================================================================================
*/
class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  /// "큰 글자 모드" 여부
  bool _isLargeText = false;

  /// 사용자 슬라이드용 PageController (자동 슬라이드 제거)
  late PageController _pageController;

  /// 가장 긴 카드의 높이를 측정하여 고정하기 위한 변수
  double _maxCardHeight = 0.0;

  /// 카드별 GlobalKey 리스트
  final List<GlobalKey> _cardKeys = [];

  /// 예시 데이터 (실제로는 fetchCollegeInfo() 결과를 받아올 수 있음)
  final List<Map<String, String>> _collegeList = [
    {
      'collegeName': '중앙대학교',
      'subjectName': '소프트웨어학부',
      'phone': '010-2797-1090',
      'email': 'sy020527@naver.com',
      'website': 'https://www.cau.ac.kr',
    },
    {
      'collegeName': '서울대학교',
      'subjectName': '컴퓨터공학부',
      'phone': '02-880-1234',
      'email': 'info@snu.ac.kr',
      'website': 'https://www.snu.ac.kr',
    },
    {
      'collegeName': '카이스트',
      'subjectName': '전산학부',
      'phone': '042-350-1234',
      'email': 'info@kaist.ac.kr',
      'website': 'https://www.kaist.ac.kr',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // 각 카드마다 key를 생성
    _cardKeys.addAll(List.generate(_collegeList.length, (_) => GlobalKey()));
    // 초기에 프레임이 그려진 뒤 최대 높이를 측정
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMaxHeight());
  }

  /// 레이아웃 변동 시(큰 글자 모드 on/off 등) 다시 측정
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMaxHeight());
  }

  /// 모든 카드(GlobalKey) 높이를 측정하여 가장 긴 높이를 찾음
  void _updateMaxHeight() {
    double maxH = 0.0;
    for (var key in _cardKeys) {
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null) {
          final h = box.size.height;
          if (h > maxH) maxH = h;
        }
      }
    }
    if (maxH != _maxCardHeight) {
      setState(() {
        _maxCardHeight = maxH;
      });
    }
  }

  /// 뒤로 가기
  void _goBack() {
    Navigator.pop(context);
  }

  /// URL 실행 (원본 코드 유지)
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  /// 원본 _infoRow 스타일 + 큰 글자 모션
  Widget _infoRow(IconData icon, String label, String content,
      {VoidCallback? onTap}) {
    // 폰트 크기 설정
    final double labelSize = _isLargeText ? 26 : 20;
    final double contentSize = _isLargeText ? 22 : 18;

    // label에 애니메이션
    final labelWidget = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 250),
      style: TextStyle(
        fontSize: labelSize,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      child: Text(label),
    );

    // content에 애니메이션
    final contentWidget = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 250),
      style: TextStyle(
        fontSize: contentSize,
        color: onTap != null ? Colors.blue : Colors.black87,
        decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Text(content),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: labelSize + 4, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelWidget,
                const SizedBox(height: 4),
                contentWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 큰 글자 모드에서 버튼 폰트 크기
  double get _buttonFontSize => _isLargeText ? 36 : 30;

  /// 화면 이동
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 배경 그라데이션
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE3E5ED),
                  Color(0xFFDADCE2),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // 오른쪽 상단 '큰 글자' 스위치
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: _isLargeText ? 28 : 23,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        child: const Text('큰 글자'),
                      ),
                      const SizedBox(width: 3),
                      Switch(
                        value: _isLargeText,
                        onChanged: (value) {
                          setState(() {
                            _isLargeText = value;
                          });
                        },
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.blueAccent,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  // 둥근 사각형 컨테이너 (카드 슬라이드 높이 = 가장 긴 카드 기준)
                  SizedBox(
                    height: _maxCardHeight > 0 ? (_maxCardHeight + 65) : 280,
                    // 초기값 200 정도 임시 설정
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withOpacity(0.3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(4, 4),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.7),
                            offset: const Offset(-4, -4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const PageScrollPhysics(), // 수동 슬라이드
                          itemCount: _collegeList.length,
                          itemBuilder: (context, index) {
                            return _buildCollegeCard(
                                index, _collegeList[index]);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // 2 x 2 버튼 (뉴모피즘)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                    children: [
                      _buildNeumorphicButton(
                        text: '대학\n이름 찾기',
                        icon: Icons.school,
                        color: const Color(0xFFFFC8D0),
                        onTap: () => _navigateTo(context, const SearchUniv()),
                      ),
                      _buildNeumorphicButton(
                        text: '과목\n이름 찾기',
                        icon: Icons.menu_book,
                        color: const Color(0xFFFFF5B3),
                        onTap: () => _navigateTo(context, const SearchSubject()),
                      ),
                      _buildNeumorphicButton(
                        text: '위치로\n찾기',
                        icon: Icons.location_on,
                        color: const Color(0xFFB7FFBF),
                        onTap: () => _navigateTo(context, const SearchGPS()),
                      ),
                      _buildNeumorphicButton(
                        text: '뒤로 가기',
                        icon: Icons.arrow_back,
                        color: const Color(0xFFB7EEFF),
                        onTap: _goBack,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 단일 카드 UI (추천 대학 + 정보)
  /// index로부터 해당 카드에 GlobalKey를 부여
  Widget _buildCollegeCard(int index, Map<String, String> info) {
    return Container(
      key: _cardKeys[index],
      color: Colors.transparent,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // 타이틀 중앙
        children: [
          // (1) '추천 대학'은 상단 중앙
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: _isLargeText ? 34 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            child: const Text("추천 대학", textAlign: TextAlign.center),
          ),
          const SizedBox(height: 10),
          // (2) 나머지 항목은 상단 정렬(좌측)
          // wrap with Expanded or Flexible if needed, but we can also just keep a Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _infoRow(
                      Icons.school,
                      "대학명",
                      info['collegeName'] ?? '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _infoRow(
                      Icons.book,
                      "학부명",
                      info['subjectName'] ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _infoRow(
                      Icons.phone,
                      "전화",
                      info['phone'] ?? '',
                      onTap: () async {
                        final Uri telUri = Uri(
                          scheme: 'tel',
                          path: info['phone'] ?? '',
                        );
                        await _launchUrl(telUri);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _infoRow(
                      Icons.email,
                      "이메일",
                      info['email'] ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _infoRow(
                Icons.link,
                "사이트",
                info['website'] ?? '',
                onTap: () async {
                  final String website = info['website'] ?? '';
                  final Uri websiteUri = Uri.parse(
                    website.startsWith('http') ? website : 'https://$website',
                  );
                  await _launchUrl(websiteUri);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 뉴모피즘 버튼
  Widget _buildNeumorphicButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(6, 6),
              blurRadius: 20,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.95),
              offset: const Offset(-6, -6),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: _buttonFontSize + 16,
                color: Colors.black87,
              ),
              const SizedBox(height: 16),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: _buttonFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
