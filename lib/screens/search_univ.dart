import 'package:bluedragonthon/services/search_api_service.dart';
import 'package:bluedragonthon/utils/university_model.dart';
import 'package:bluedragonthon/widgets/university_widgets.dart';
import 'package:flutter/material.dart';

class SearchUniv extends StatefulWidget {
  const SearchUniv({super.key});

  @override
  _SearchUnivState createState() => _SearchUnivState();
}

class _SearchUnivState extends State<SearchUniv> {
  final TextEditingController _nameController = TextEditingController();
  List<University> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 검색 API 호출 (기존 로직 그대로 유지)
  Future<void> _searchUniversity() async {
    final String searchText = _nameController.text.trim();
    if (searchText.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _searchResults = [];
    });

    try {
      // 대학 이름 검색 API: 세부 주소로 '/api/college/name' 전달
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

  /// 하트 토글 (기존 로직 그대로 유지)
  Future<void> _toggleHeart(University univ) async {
    print('토글 요청: 대학 ID = ${univ.id}');
    try {
      final newState =
      await UniversityService.toggleHeart(univ.id, univ.isHeart);
      setState(() {
        _searchResults = _searchResults.map((u) {
          if (u.id == univ.id) {
            return University(
              id: u.id,
              name: u.name,
              contactInfo: u.contactInfo,
              address: u.address,
              isHeart: newState,
              program: u.program,
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
    final bool hasResults = _searchResults.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 검색 영역
            // AnimatedContainer로 높이와 정렬을 자연스럽게 전환
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // 검색 결과가 없을 때는 중앙에 크게 위치시킴,
              // 결과가 있으면 상단(좀 더 작은 높이)으로 이동
              height: hasResults
                  ? 130
                  : MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              alignment:
              hasResults ? Alignment.topCenter : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: hasResults
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.center,
                children: [
                  // 검색 전에는 큰 타이틀, 검색 후에는 숨김
                  if (!hasResults)
                    const Text(
                      "이름으로 대학교 찾기",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 10),

                  // TextField + 검색 버튼 (버튼 로직은 기존 유지)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(fontSize: 25),
                            decoration: InputDecoration(
                              hintText: '원하는 대학교를 검색해보세요',
                              hintStyle: const TextStyle(
                                color: Colors.black54,
                                fontSize: 20,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0),
                                borderSide: const BorderSide(
                                  width: 2,
                                  color: Colors.grey,
                                ),
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
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _searchUniversity,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            backgroundColor:
                            Theme.of(context).primaryColor,
                            fixedSize: const Size(100, 60),
                          ),
                          child: const Text(
                            "검색",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 검색 결과 영역
            const SizedBox(height: 20),
            if (_isLoading)
            // 로딩
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
            // 에러
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (hasResults)
              // 결과 리스트
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final univ = _searchResults[index];

                      // 뉴모피즘 컨테이너로 감싸기
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(-4, -4),
                                blurRadius: 6,
                              ),
                              BoxShadow(
                                color: Colors.grey.shade600,
                                offset: const Offset(4, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: UniversityListItem(
                            university: univ,
                            onToggleHeart: () => _toggleHeart(univ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
              // 아직 아무것도 검색 안 했거나, 검색했으나 결과가 없을 때
              // (결과가 정말 없는 경우도 hasResults=false이므로 여기로 들어옴)
                const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
