import 'package:bluedragonthon/utils/token_manager.dart';
import 'package:bluedragonthon/widgets/university_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 진동 효과
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bluedragonthon/utils/university_model.dart';
import 'package:bluedragonthon/services/search_api_service.dart';
import 'package:bluedragonthon/utils/university_model.dart';

// 아래 두 개는 SearchUniv 예시처럼:
//  - University : id, name, contactInfo, address, program, bool isHeart
//  - UniversityListItem : 하트 토글 UI
import 'package:bluedragonthon/utils/university_model.dart';
import 'package:bluedragonthon/widgets/university_widgets.dart';

class SearchGPS extends StatefulWidget {
  const SearchGPS({Key? key}) : super(key: key);

  @override
  State<SearchGPS> createState() => _SearchGPSState();
}

class _SearchGPSState extends State<SearchGPS> {
  final TextEditingController _finalAddressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchView = false;   // (메인 화면 vs 주소검색 화면)
  bool _isSearching = false;    // 주소 검색 로딩

<<<<<<< HEAD
  // 검색 결과 (주소 문자열) 및 각 결과의 위도/경도 정보
  List<String> _searchResults = [];
  final List<Offset> _searchCoords = [];
=======
  // -------------------------------
  // 주소 검색 결과
  List<String> _searchResults = [];
  List<Offset> _searchCoords = [];
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee

  // 주거지 캐시된 좌표
  double _cachedLat = 0.0;
  double _cachedLng = 0.0;

  // 선택된 주소 (메인 TextField 표시)
  double _selectedLat = 0.0;
  double _selectedLng = 0.0;

<<<<<<< HEAD
  // 백엔드로부터 받아온 대학교 리스트
  List<University> _universities = [];
=======
  // -------------------------------
  // **대학 리스트** (거리검색 결과)
  bool _showDistanceResult = false; // 대학 리스트 화면 표시중인가?
  bool _distanceLoading = false;    // 로딩 상태
  String? _distanceError;           // 에러 메시지

  // **여기가 핵심**: SearchUniv 예시처럼, University 모델로 리스트를 관리
  List<University> _distanceResults = [];
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee

  @override
  void initState() {
    super.initState();
    _loadCachedLocation();
  }

  /// 초기에는 캐시된 주거지 주소를 TextField에 넣지 않음
  /// 좌표만 캐싱
  Future<void> _loadCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedLat = prefs.getDouble('userLocationLat') ?? 0.0;
    _cachedLng = prefs.getDouble('userLocationLng') ?? 0.0;
  }

  /// 뒤로가기 or 검색 닫기
  void _onBackOrClose() {
    HapticFeedback.lightImpact();

    // 만약 대학 리스트를 보고 있으면 → 주소 검색 리스트로 복귀
    if (_showDistanceResult) {
      setState(() {
        _showDistanceResult = false;
        _distanceResults.clear();
        _distanceError = null;
        _distanceLoading = false;
      });
      return;
    }

    // 주소 검색 화면이면 → 메인화면
    if (_isSearchView) {
      setState(() {
        _isSearchView = false;
        _searchController.clear();
        _searchResults.clear();
        _searchCoords.clear();
      });
    } else {
      // 메인화면이면 pop
      Navigator.pop(context);
    }
  }

<<<<<<< HEAD
  /// "검색하기" 버튼을 누르면 선택된 주소의 위도/경도 정보를 백엔드로 전송하여
  /// 대학교 리스트를 받아오고, 메인 화면 하단에 스크롤 가능한 리스트로 출력합니다.
=======
  /// 서버로 위치 전송(원한다면)
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee
  Future<void> _sendLocationToBackend() async {
    final addr = _finalAddressController.text.trim();
    if (addr.isEmpty) {
      HapticFeedback.mediumImpact();
      _showSnackBar('주소가 비어있습니다.');
      return;
    }
    try {
<<<<<<< HEAD
      final universities = await UniversityService.sendLocationData(
        acr: _selectedLat,
        dwn: _selectedLng,
        page: 0,
      );
      await _saveLocation(addr, _selectedLat, _selectedLng);
      setState(() {
        _universities = universities;
      });
      if (_universities.isEmpty) {
        _showSnackBar('검색 결과가 없습니다.');
      }
=======
      final response = await ApiService.searchCollege(page: 0);
      _showSnackBar('위치 전송 성공(샘플): 총${response.result.result.length}개 대학');
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee
    } catch (e) {
      _showSnackBar('위치 전송 실패: $e');
    }
  }

  /// 메인화면 -> 검색화면
  void _openSearchView() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSearchView = true;
      _searchController.clear();
      _searchResults.clear();
      _searchCoords.clear();
    });
  }

  /// 검색어 주소 검색
  Future<void> _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      HapticFeedback.mediumImpact();
      _showSnackBar('검색어를 입력해주세요.');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults.clear();
      _searchCoords.clear();
      _showDistanceResult = false;
    });

    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        _showSnackBar('검색 결과가 없습니다.');
      } else {
        HapticFeedback.lightImpact();
      }
      final List<String> names = [];
      final List<Offset> coords = [];

      for (final loc in locations) {
        final pms = await placemarkFromCoordinates(loc.latitude, loc.longitude);
        for (final p in pms) {
          final addr = _formatPlacemark(p);
          if (addr.isNotEmpty && !names.contains(addr)) {
            names.add(addr);
            coords.add(Offset(loc.latitude, loc.longitude));
          }
        }
      }

      setState(() {
        _searchResults.addAll(names);
        _searchCoords.addAll(coords);
      });
    } catch (e) {
      _showSnackBar('주소 검색 실패: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  /// GPS 기반
  Future<void> _onLocationBasedSearch() async {
    setState(() {
      _isSearching = true;
      _searchResults.clear();
      _searchCoords.clear();
      _showDistanceResult = false;
    });

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _showSnackBar('위치 권한 거부');
          setState(() => _isSearching = false);
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        _showSnackBar('위치 권한 영구 거부. 설정 필요');
        setState(() => _isSearching = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final List<String> names = [];
      final List<Offset> coords = [];

      final pms =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);
      for (final p in pms) {
        final addr = _formatPlacemark(p);
        if (addr.isNotEmpty && !names.contains(addr)) {
          names.add(addr);
          coords.add(Offset(pos.latitude, pos.longitude));
        }
      }
      setState(() {
        _searchResults = names;
        _searchCoords = coords;
      });
    } catch (e) {
      _showSnackBar('GPS 오류: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  /// 캐시된 주거지
  Future<void> _onCachedLocationSearch() async {
    if (_cachedLat == 0.0 && _cachedLng == 0.0) {
      _showSnackBar('등록된 주거지 정보가 없습니다.');
      return;
    }
    setState(() {
      _isSearching = true;
      _searchResults.clear();
      _searchCoords.clear();
      _showDistanceResult = false;
    });

    try {
      final pms = await placemarkFromCoordinates(_cachedLat, _cachedLng);
      final List<String> names = [];
      final List<Offset> coords = [];

      for (final p in pms) {
        final addr = _formatPlacemark(p);
        if (addr.isNotEmpty && !names.contains(addr)) {
          names.add(addr);
          coords.add(Offset(_cachedLat, _cachedLng));
        }
      }
      setState(() {
        _searchResults = names;
        _searchCoords = coords;
      });
    } catch (e) {
      _showSnackBar('주거지 주소 불러오기 실패: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  /// 주소 탭 → 직선거리 검색 API → 결과를 같은 화면에 표시
  Future<void> _onSelectResultIndex(int index) async {
    HapticFeedback.lightImpact();

    // 1) 사용자가 탭한 주소를 메인뷰의 TextField에도 표시
    final selectedAddress = _searchResults[index];
    final lat = _searchCoords[index].dx;
    final lng = _searchCoords[index].dy;

    setState(() {
      _finalAddressController.text = selectedAddress;
      _selectedLat = lat;
      _selectedLng = lng;
    });

    // 2) distanceSearchCollege 호출
    setState(() {
      _showDistanceResult = true;
      _distanceLoading = true;
      _distanceError = null;
      _distanceResults.clear();
    });

    try {
      final resp = await ApiService.distanceSearchCollege(
        acr: lat,
        dwn: lng,
        page: 0,
      );

      // (중요) LikeUnivItem -> University 변환, 'favorites' -> 'isHeart'
      final univList = resp.result.result.map((item) {
        return University(
          id: item.id,
          name: item.name,
          contactInfo: item.contactInfo,
          address: item.address,
          program: item.program,
          isHeart: item.favorites,
        );
      }).toList();

      setState(() {
        _distanceResults = univList;
      });
    } catch (e) {
      setState(() {
        _distanceError = e.toString();
      });
    } finally {
      setState(() => _distanceLoading = false);
    }
  }

  /// (SearchUniv 와 동일) 하트 토글
  Future<void> _toggleDistanceHeart(University univ) async {
    print('토글 요청(거리리스트): 대학 ID = ${univ.id}');
    try {
      // SearchUniv 처럼 호출
      final newState = await UniversityService.toggleHeart(univ.id, univ.isHeart);
      setState(() {
        // 리스트 갱신
        _distanceResults = _distanceResults.map((u) {
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

  /// Placemark → 문자열
  String _formatPlacemark(Placemark place) {
    final parts = [
      place.country ?? '',
      place.administrativeArea ?? '',
      place.subAdministrativeArea ?? '',
      place.locality ?? '',
      place.thoroughfare ?? '',
      place.subThoroughfare ?? '',
    ];
    final valid = parts.where((p) => p.isNotEmpty).toList();
    return valid.join(' ');
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 대학교 리스트 항목의 하트(즐겨찾기) 상태를 토글합니다.
  Future<void> _toggleHeart(University university, int index) async {
    try {
      final newHeartState = await UniversityService.toggleHeart(
          university.id, university.isHeart);
      setState(() {
        _universities[index] = University(
          id: university.id,
          name: university.name,
          contactInfo: university.contactInfo,
          address: university.address,
          isHeart: newHeartState,
          program: university.program,
        );
      });
    } catch (e) {
      _showSnackBar('하트 업데이트 실패: $e');
    }
  }

  @override
  void dispose() {
    _finalAddressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSearchView
                    ? _buildSearchView()
                    : _buildMainView(), // 메인 vs 검색
              ),
            ),
            // 상단 왼쪽 아이콘
            Positioned(
              top: 5,
              left: 10,
              child: IconButton(
                icon: Icon(
                  // 대학 리스트 보는 중이면 close, 아니면 검색화면 여부 따라
                  _showDistanceResult ? Icons.close
                      : (_isSearchView ? Icons.close : Icons.arrow_back),
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

<<<<<<< HEAD
  /// 메인 뷰: 선택된 주소(읽기 전용 텍스트필드), 검색, "검색하기" 버튼과
  /// 백엔드에서 받아온 대학교 리스트(스와이프 가능)를 출력합니다.
=======
  /// 메인 뷰
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee
  Widget _buildMainView() {
    return Container(
      key: const ValueKey('MainView'),
      width: double.infinity,
<<<<<<< HEAD
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '위치로 대학 찾기',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: SizedBox(
=======
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '위치로 대학 찾기',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: TextField(
                      controller: _finalAddressController,
                      readOnly: true,
                      style: const TextStyle(fontSize: 25),
                      decoration: InputDecoration(
                        hintText: '주소를 검색해주세요!',
                        hintStyle: const TextStyle(
                          color: Colors.black54,
                          fontSize: 25,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide:
                          const BorderSide(width: 2, color: Colors.grey),
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
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee
                  height: 60,
                  child: TextField(
                    controller: _finalAddressController,
                    readOnly: true,
                    style: const TextStyle(fontSize: 25),
                    decoration: InputDecoration(
                      hintText: '주소를 선택하세요',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontSize: 25,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                        borderSide:
                            const BorderSide(width: 2, color: Colors.grey),
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
<<<<<<< HEAD
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _openSearchView,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    fixedSize: const Size(100, 60),
                  ),
                  child: const Icon(Icons.gps_fixed, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // "검색하기" 버튼: 위/경도 정보를 백엔드로 전송하고 대학교 리스트를 업데이트합니다.
          ElevatedButton(
            onPressed: _sendLocationToBackend,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              textStyle: const TextStyle(
                  fontSize: 25, fontWeight: FontWeight.bold),
            ),
            child: const Text("검색하기"),
          ),
          const SizedBox(height: 20),
          // 대학교 리스트가 있을 경우 아래에 스크롤 가능한 리스트로 출력합니다.
          if (_universities.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _universities.length,
                itemBuilder: (context, index) {
                  final uni = _universities[index];
                  return UniversityListItem(
                    university: uni,
                    onToggleHeart: () => _toggleHeart(uni, index),
                  );
                },
              ),
            ),
        ],
=======
                    child: const Text(
                      '검색',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),
          ],
        ),
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee
      ),
    );
  }

<<<<<<< HEAD
  /// 검색 뷰: 주소 검색을 위한 텍스트필드, 검색 버튼, 위치 기반 검색 버튼, 그리고
  /// 검색 결과 목록(주소 선택 시 메인 화면에 반영)
=======
  /// 검색 뷰
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee
  Widget _buildSearchView() {
    return Container(
      key: const ValueKey('SearchView'),
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 70),
          // 검색어 입력
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 22),
                    decoration: InputDecoration(
                      hintText: '검색어 입력',
<<<<<<< HEAD
                      hintStyle: const TextStyle(
                          color: Colors.black54, fontSize: 20),
=======
                      hintStyle:
                      const TextStyle(color: Colors.black54, fontSize: 20),
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                        borderSide:
                        const BorderSide(width: 2, color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                        borderSide: BorderSide(
                          width: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    fixedSize: const Size(80, 50),
                  ),
                  child: const Text(
                    '검색',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // 주거지 + GPS
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _onCachedLocationSearch,
                    icon: const Icon(Icons.home, color: Colors.black87),
                    label: const Text(
                      '주거지 주변 주소',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _onLocationBasedSearch,
                    icon: const Icon(Icons.gps_fixed, color: Colors.black87),
                    label: const Text(
                      '위치 기반 검색',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 만약 대학교 리스트 화면을 보고 있다면 대학교 목록 표시, 아니면 주소 검색결과
          Expanded(
            child: _showDistanceResult
                ? _buildDistanceResultList()
                : _buildAddressResultList(),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  /// 주소 검색 결과 목록 (리스트뷰). 각 결과를 선택하면 _onSelectResultIndex가 호출됩니다.
  Widget _buildSearchResults() {
=======
  /// 주소 검색 결과
  Widget _buildAddressResultList() {
>>>>>>> 5648e135416b4f9072772fe14f531422be8b95ee
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다.', style: TextStyle(fontSize: 18)),
      );
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, idx) {
        final addr = _searchResults[idx];
        return ListTile(
          title: Text(addr, style: const TextStyle(fontSize: 20)),
          onTap: () => _onSelectResultIndex(idx), // 탭하면 거리검색 후 대학 리스트 표시
        );
      },
    );
  }

  /// (SearchUniv 처럼) 거리 검색 후 받아온 대학 리스트
  Widget _buildDistanceResultList() {
    if (_distanceLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_distanceError != null) {
      return Center(
        child: Text(
          '에러: $_distanceError',
          style: const TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }
    if (_distanceResults.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다.', style: TextStyle(fontSize: 18)),
      );
    }

    // **SearchUniv 코드처럼 UniversityListItem + onToggleHeart**
    return ListView.builder(
      itemCount: _distanceResults.length,
      itemBuilder: (context, index) {
        final univ = _distanceResults[index];
        return UniversityListItem(
          university: univ,
          onToggleHeart: () => _toggleDistanceHeart(univ),
        );
      },
    );
  }
}
