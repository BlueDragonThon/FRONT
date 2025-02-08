import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 진동
import 'package:shared_preferences/shared_preferences.dart';

class MobileLocationInputScreen extends StatefulWidget {
  const MobileLocationInputScreen({Key? key}) : super(key: key);

  @override
  State<MobileLocationInputScreen> createState() =>
      _MobileLocationInputScreenState();
}

class _MobileLocationInputScreenState extends State<MobileLocationInputScreen> {
  // 메인에 표시할, 최종 선택된 주소(읽기 전용)
  final TextEditingController _finalAddressController =
  TextEditingController(text: '');

  // 확장된 검색 영역에서 사용할 검색어 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchExpanded = false; // 검색 영역 보이기/숨기기
  bool _isSearching = false;      // 검색 중 표시(스피너 등)
  List<String> _searchResults = [];  // 검색 결과 리스트

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  /// SharedPreferences에서 저장된 주소 로드 -> 읽기 전용 필드에 표시
  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocation = prefs.getString('userLocation') ?? '';
    setState(() {
      _finalAddressController.text = savedLocation;
    });
  }

  /// 최종 주소를 SharedPreferences에 저장
  Future<void> _saveLocation(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userLocation', address);
  }

  /// "주소 검색" 버튼 누르면 검색 영역 확장
  void _toggleSearchPanel() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
  }

  /// 실제 주소 검색 로직 (여기서는 예시로 더미 데이터 사용)
  void _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      HapticFeedback.mediumImpact(); // 오류 느낌
      _showSnackBar('검색어를 입력해주세요.');
      return;
    }
    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });

    // 실제 API 등 호출 대신, 1초 지연 후 "가짜 결과" 표시
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isSearching = false;
      // 더미 예시: 검색어를 포함하는 가짜 주소 목록
      _searchResults = [
        '$query 1번가',
        '$query 2번가',
        '$query 3번가',
      ];
    });
    HapticFeedback.lightImpact(); // 검색 완료 시 가벼운 진동
  }

  /// "위치 기반으로 검색" 버튼 예시 (실제 구현은 자유)
  void _onLocationBasedSearch() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });
    // 위치 기반 검색 로직(예: GPS, API 연동 등) -> 여기선 더미
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isSearching = false;
      _searchResults = [
        '내 주변 1번가',
        '내 주변 2번가',
        '내 주변 3번가',
      ];
    });
  }

  /// 검색 결과 중 하나 선택 -> 메인 주소 필드에 입력 -> 검색 영역 닫기
  void _onSelectResult(String selected) {
    HapticFeedback.lightImpact();
    setState(() {
      _finalAddressController.text = selected;
      _isSearchExpanded = false; // 검색 영역 닫기
    });
  }

  /// 뒤로가기 -> 이전 화면
  void _goBack() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  /// "다음" 버튼 -> 메인 화면 (예시)
  void _onNext() async {
    if (_finalAddressController.text.trim().isEmpty) {
      HapticFeedback.mediumImpact();
      _showSnackBar('거주 지역을 입력해주세요.');
      return;
    }
    // 정상
    HapticFeedback.lightImpact();
    await _saveLocation(_finalAddressController.text.trim());

    // 예: FadeTransition으로 메인 화면 이동
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const _DummyMainScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      '어디에 사시나요?',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // 읽기 전용 주소 필드 + "주소 검색" 버튼
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _finalAddressController,
                            readOnly: true, // 수정 불가
                            style: const TextStyle(fontSize: 25),
                            decoration: InputDecoration(
                              hintText: '주소를 선택하세요',
                              hintStyle: const TextStyle(
                                color: Colors.black54,
                                fontSize: 25,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // "주소 검색" 버튼
                        ElevatedButton(
                          onPressed: _toggleSearchPanel,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            minimumSize: const Size(80, 60),
                          ),
                          child: const Text(
                            '검색',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // "다음" 버튼 (원형, Hero)
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

            // (2) 뒤로가기 버튼
            Positioned(
              top: 5,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 50),
                onPressed: _goBack,
              ),
            ),

            // (3) 검색 영역 (AnimatedCrossFade 또는 AnimatedSwitcher)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              // AnimatedCrossFade를 사용해 패널을 펼치거나 숨김
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _isSearchExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _buildSearchPanel(), // 펼쳐진 검색 영역
                secondChild: const SizedBox.shrink(), // 빈 공간
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 펼쳐진 검색 영역 UI
  Widget _buildSearchPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용만큼 높이
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // 검색어 입력
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: '검색어 입력',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // "검색" 버튼
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(80, 48),
                  ),
                  child: const Text(
                    '검색',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 위치 기반으로 검색 (요청 사항에 따라 남겨둔 버튼)
            ElevatedButton(
              onPressed: _onLocationBasedSearch,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                backgroundColor: Colors.grey.shade200,
                elevation: 0,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                '위치 기반으로 검색',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // 검색 결과 리스트
            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_searchResults.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  '검색 결과가 없습니다.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
            // 결과 리스트
              SizedBox(
                height: 200, // 예시 높이
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return ListTile(
                      title: Text(item, style: const TextStyle(fontSize: 18)),
                      onTap: () => _onSelectResult(item),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 메인 화면 예시
class _DummyMainScreen extends StatelessWidget {
  const _DummyMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '메인 화면',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
