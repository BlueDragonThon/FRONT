import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluedragonthon/services/search_api_service.dart';
import 'package:bluedragonthon/utils/university_model.dart';
import 'package:bluedragonthon/widgets/university_widgets.dart';

class SearchUniv extends StatefulWidget {
  const SearchUniv({Key? key}) : super(key: key);

  @override
  State<SearchUniv> createState() => _SearchUnivState();
}

class _SearchUnivState extends State<SearchUniv> {
  final TextEditingController _nameController = TextEditingController();

  bool _searched = false;         // 검색 버튼을 눌렀는지 여부
  bool _isLoading = false;        // 로딩 상태
  String? _error;                 // 에러 메시지
  List<University> _searchResults = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 좌상단 아이콘: 검색 중이면 X, 아니면 뒤로가기
  void _onBackOrClose() {
    HapticFeedback.lightImpact();
    if (_searched) {
      // 검색 초기화
      setState(() {
        _searched = false;
        _searchResults.clear();
        _nameController.clear();
        _error = null;
        _isLoading = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  /// (수정 금지) 실제 검색 로직
  Future<void> _searchUniversity() async {
    final String searchText = _nameController.text.trim();
    if (searchText.isEmpty) return;

    setState(() {
      _searched = true; // 버튼 누르면 상단으로 이동
      _isLoading = true;
      _error = null;
      _searchResults = [];
    });

    try {

      final results = await UniversityService.searchUniversity(
        searchText,
        '/api/college/name',
      );

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// (수정 금지) 하트 토글
  Future<void> _toggleHeart(University univ) async {
    print('토글 요청: 대학 ID = ${univ.id}');
    try {
      final newState =
<<<<<<< HEAD
          await UniversityService.toggleHeart(univ.id, univ.isHeart);
=======
      await UniversityService.toggleHeart(univ.id, univ.isHeart);
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee
      setState(() {
        // 현재 리스트 갱신
        _searchResults = _searchResults.map((u) {
          if (u.id == univ.id) {
            return University(
              id: u.id,
              name: u.name,
              contactInfo: u.contactInfo,
              address: u.address,
              program: u.program,
              isHeart: newState,
            );
          }
          return u;
        }).toList();
      });
    } catch (e) {
      print('하트 요청 중 에러: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 키보드 열려도 화면 자체는 그대로 (search bar 위치 고정)
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 바깥 터치 시 포커스 해제
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque, // 수정: 어느 영역이든 터치 수용
              child: _buildBody(),
            ),

            // 좌측 상단 아이콘
            Positioned(
              top: 5,
              left: 10,
              child: IconButton(
                icon: Icon(
                  _searched ? Icons.close : Icons.arrow_back,
                  size: 50,
                  color: Colors.black,
                ),
                onPressed: _onBackOrClose,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메인 바디: Stack 안에서 검색바와 리스트를 배치
  Widget _buildBody() {
    return Stack(
      children: [
        // 결과 리스트 (아래 쪽)
        Positioned.fill(
          top: 180,
          child: _buildResultWidget(),
        ),

        // 검색 바
        // 검색 전에는 "중앙(높은 top)" -> 검색 후에는 "상단 (top=100)"
        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          left: 0,
          right: 0,
          // 검색 전이면 대략 화면 중간, 검색 후엔 top=100
          top: _searched ? 100 : MediaQuery.of(context).size.height * 0.33,
          child: _buildSearchBar(),
        ),
      ],
    );
  }

  /// 검색바(텍스트필드 + 버튼)
  Widget _buildSearchBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_searched)
          const Text(
            '이름으로 대학교 찾기',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
        if (!_searched)
          const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 280,
              height: 60,
              child: TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 25),
                decoration: InputDecoration(
                  hintText: '대학교를 검색해보세요!',
                  hintStyle:
                  const TextStyle(color: Colors.black54, fontSize: 23),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: const BorderSide(width: 2, color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide(
                      width: 2,
                      color: Theme.of(context).primaryColor,
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
            SizedBox(
              width: 100,
              height: 60,
              child: ElevatedButton(
                onPressed: _searchUniversity,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  '검색',
                  style: TextStyle(fontSize: 23, color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }

  /// 검색 결과 (로딩/에러/결과)
  Widget _buildResultWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red, fontSize: 20),
        ),
      );
    }
    // 검색을 했지만 결과가 비었을 때
    if (_searched && _searchResults.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    // 실제 결과 리스트
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final univ = _searchResults[index];
        return UniversityListItem(
          university: univ,
          onToggleHeart: () => _toggleHeart(univ),
        );
      },
    );
  }
}
