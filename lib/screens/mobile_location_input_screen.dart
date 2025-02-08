import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 진동
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// 메인 화면 (나중에 넘어갈 때 FadeTransition)
import 'mobile_main_screen.dart';
import 'package:bluedragonthon/services/api_service.dart';
import 'package:bluedragonthon/utils/token_manager.dart';

class MobileLocationInputScreen extends StatefulWidget {
  const MobileLocationInputScreen({Key? key}) : super(key: key);

  @override
  State<MobileLocationInputScreen> createState() =>
      _MobileLocationInputScreenState();
}

class _MobileLocationInputScreenState extends State<MobileLocationInputScreen> {
  final TextEditingController _finalAddressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchView = false;
  bool _isSearching = false;

  // 기존 검색 결과 목록 (주소 문자열)
  List<String> _searchResults = [];

  // 새로 추가: 각 검색 결과에 대한 (lat, lng) 정보를 저장
  final List<Offset> _searchCoords = [];

  // 최종 선택된 위도/경도
  double _selectedLat = 0.0;
  double _selectedLng = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  // SharedPreferences에서 기존 주소 로드
  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('userLocation') ?? '';
    setState(() {
      _finalAddressController.text = saved;
    });
    // 만약 lat/lng가 이미 저장돼있다면 불러올 수도 있음
    _selectedLat = prefs.getDouble('userLocationLat') ?? 0.0;
    _selectedLng = prefs.getDouble('userLocationLng') ?? 0.0;
  }

  // 위치 정보(이름, 위도, 경도)를 함께 저장
  Future<void> _saveLocation(String name, double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userLocation', name);
    await prefs.setDouble('userLocationLat', lat);
    await prefs.setDouble('userLocationLng', lng);
  }

  /// 검색 뷰면 X, 메인 뷰면 뒤로가기
  void _onBackOrClose() {
    HapticFeedback.lightImpact();
    if (_isSearchView) {
      setState(() {
        _isSearchView = false;
        _searchController.clear();
        _searchResults.clear();
        _searchCoords.clear();
      });
    } else {
      Navigator.pop(context);
    }
  }

  /// "다음" 버튼 -> 메인 화면 (FadeTransition)
  void _onNext() async {
    HapticFeedback.lightImpact();

    final addr = _finalAddressController.text.trim();
    if (addr.isEmpty) {
      HapticFeedback.mediumImpact();
      _showSnackBar('거주 지역을 입력해주세요.');
      return;
    }

    // 1) 위치 정보(이름, lat, lng) 저장
    await _saveLocation(addr, _selectedLat, _selectedLng);

    // 2) 회원가입 API 호출 -> 토큰 저장 (예시)
    try {
      final signupBody = {
        "name": addr, // 주소를 name으로 가정
        "age": 20,
        "acr": 0,
        "dwn": 0,
      };

      final signupResponse = await ApiService.signupMember(signupBody);
      if (signupResponse.isSuccess && signupResponse.result != null) {
        await TokenManager.saveToken(signupResponse.result!.token);
      } else {
        _showSnackBar('회원가입 실패: ${signupResponse.message}');
        return; // 여기서 중단
      }
    } catch (e) {
      _showSnackBar('회원가입 중 오류 발생: $e');
      return; // 여기서 중단
    }

    // 3) FadeTransition으로 메인으로 이동
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MobileMainScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// 검색 화면 열기
  void _openSearchView() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSearchView = true;
      _searchController.clear();
      _searchResults.clear();
      _searchCoords.clear();
    });
  }

  /// 주소 검색 -> 여러 결과 + 각 lat/lng
  Future<void> _onSearch() async {
    HapticFeedback.lightImpact();
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
    });

    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        HapticFeedback.mediumImpact();
        _showSnackBar('검색 결과가 없습니다.');
        setState(() => _isSearching = false);
        return;
      }

      final List<String> foundNames = [];
      final List<Offset> foundCoords = [];

      for (final loc in locations) {
        final placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
        for (final place in placemarks) {
          final addr = _formatPlacemark(place);
          if (addr.isNotEmpty) {
            if (!foundNames.contains(addr)) {
              foundNames.add(addr);
              foundCoords.add(Offset(loc.latitude, loc.longitude));
            }
          }
        }
      }

      if (foundNames.isEmpty) {
        HapticFeedback.mediumImpact();
        _showSnackBar('검색 결과가 없습니다.');
      } else {
        HapticFeedback.lightImpact();
      }

      setState(() {
        _searchResults = foundNames;
        _searchCoords.addAll(foundCoords);
        _isSearching = false;
      });
    } catch (e) {
      HapticFeedback.mediumImpact();
      _showSnackBar('주소 검색 실패. 다시 시도해주세요.');
      setState(() => _isSearching = false);
    }
  }

  /// GPS -> 위경도 -> placemarks -> 주소 목록
  Future<void> _onLocationBasedSearch() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isSearching = true;
      _searchResults.clear();
      _searchCoords.clear();
    });

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _showSnackBar('위치 권한이 거부되었습니다.');
          setState(() => _isSearching = false);
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        _showSnackBar('위치 권한이 영구적으로 거부되었습니다. 설정에서 허용해주세요.');
        setState(() => _isSearching = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);

      final List<String> foundNames = [];
      final List<Offset> foundCoords = [];

      for (final p in placemarks) {
        final addr = _formatPlacemark(p);
        if (addr.isNotEmpty && !foundNames.contains(addr)) {
          foundNames.add(addr);
          foundCoords.add(Offset(pos.latitude, pos.longitude));
        }
      }

      if (foundNames.isEmpty) {
        HapticFeedback.mediumImpact();
        _showSnackBar('현재 위치 검색 결과가 없습니다.');
      } else {
        HapticFeedback.lightImpact();
      }
      setState(() {
        _searchResults = foundNames;
        _searchCoords.addAll(foundCoords);
        _isSearching = false;
      });
    } catch (e) {
      HapticFeedback.mediumImpact();
      _showSnackBar('현재 위치를 가져올 수 없습니다. 다시 시도해주세요.');
      setState(() => _isSearching = false);
    }
  }

  /// 특정 인덱스의 결과 선택 -> 메인 주소 필드 + lat/lng
  void _onSelectResultIndex(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _finalAddressController.text = _searchResults[index];
      _selectedLat = _searchCoords[index].dx; // lat
      _selectedLng = _searchCoords[index].dy; // lng
      _isSearchView = false;
    });
  }

  /// Placemark -> 문자열
  String _formatPlacemark(Placemark place) {
    final parts = [
      place.country,
      place.administrativeArea,
      place.subAdministrativeArea,
      place.locality,
      place.thoroughfare,
      place.subThoroughfare,
    ];
    final valid = parts.where((p) => p != null && p.isNotEmpty).toList();
    return valid.join(' ');
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // AnimatedSwitcher로 메인 / 검색 뷰 교체
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSearchView ? _buildSearchView() : _buildMainView(),
              ),
            ),

            // 왼쪽 상단 아이콘
            Positioned(
              top: 5,
              left: 10,
              child: IconButton(
                icon: Icon(
                  _isSearchView ? Icons.close : Icons.arrow_back,
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

  /// 메인(주소 필드 + 다음버튼)
  Widget _buildMainView() {
    return Container(
      key: const ValueKey('MainView'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '어디에 사시나요?',
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
                    child: const Text(
                      '검색',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // 다음 버튼 (원형, Hero)
            Hero(
              tag: 'transitionCircle',
              child: SizedBox(
                width: 80,
                height: 80,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: const CircleBorder(),
                    backgroundColor: Theme.of(context).primaryColor,
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
    );
  }

  /// 검색 뷰
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
                      hintStyle:
                      const TextStyle(color: Colors.black54, fontSize: 20),
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
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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

          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onLocationBasedSearch,
              icon: const Icon(Icons.gps_fixed, color: Colors.black87),
              label: const Text(
                '위치 기반으로 검색',
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
          const SizedBox(height: 16),

          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
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
        final item = _searchResults[idx];
        return ListTile(
          title: Text(item, style: const TextStyle(fontSize: 20)),
          onTap: () => _onSelectResultIndex(idx),
        );
      },
    );
  }
}
