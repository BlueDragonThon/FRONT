// search_univ.dart
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

  Future<void> _searchUniversity() async {
    final String searchText = _nameController.text.trim();
    if (searchText.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _searchResults = [];
    });

    try {
      // 대학 이름 검색 API: 세부 주소로 '/university/search' 전달
      final results = await UniversityService.searchUniversity(searchText, '/api/collage');
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

  Future<void> _toggleHeart(University univ) async {
    try {
      final newState = await UniversityService.toggleHeart(univ.id, univ.isHeart);
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
    // 기존의 UI 구성...
    return Scaffold(
      appBar: AppBar(
        title: const Text("대학교 검색"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            const Text(
              "이름으로 대학교 찾기",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 25),
              decoration: InputDecoration(
                labelText: '원하는 대학교를 검색해보세요',
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 86, 86, 86)),
                hintText: '예) 서울 노인대학',
                hintStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchUniversity,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                textStyle:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              child: const Text("검색하기"),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 20),
                ),
              )
            else if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final univ = _searchResults[index];
                    return UniversityListItem(
                      university: univ,
                      onToggleHeart: () => _toggleHeart(univ),
                    );
                  },
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
