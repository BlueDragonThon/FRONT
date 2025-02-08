import 'package:bluedragonthon/services/api_service.dart';
import 'package:bluedragonthon/utils/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 진동 효과
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bluedragonthon/services/search_api_service.dart';

class SearchGPS extends StatefulWidget {
  const SearchGPS({super.key});

  @override
  State<SearchGPS> createState() => _SearchGPSState();
}

class _SearchGPSState extends State<SearchGPS> {
  final TextEditingController _finalAddressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // 메인 화면과 검색 화면을 전환하는 플래그
  bool _isSearchView = false;
  // 검색 중 표시할 인디케이터 플래그
  bool _isSearching = false;

  // 검색 결과 (주소 문자열)
  List<String> _searchResults = [];
  // 각 결과에 해당하는 위도/경도 정보 (Offset.dx: latitude, dy: longitude)
  final List<Offset> _searchCoords = [];

  // 최종 선택된 위치의 위도/경도
  double _selectedLat = 0.0;
  double _selectedLng = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  // SharedPreferences에서 저장된 위치(주소, 위도, 경도)를 불러옵니다.
  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('userLocation') ?? '';
    setState(() {
      _finalAddressController.text = saved;
    });
    _selectedLat = prefs.getDouble('userLocationLat') ?? 0.0;
    _selectedLng = prefs.getDouble('userLocationLng') ?? 0.0;
  }

  // 선택된 위치 정보를 SharedPreferences에 저장합니다.
  Future<void> _saveLocation(String name, double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userLocation', name);
    await prefs.setDouble('userLocationLat', lat);
    await prefs.setDouble('userLocationLng', lng);
  }

  /// 검색 화면이 열려 있다면 닫고, 아니라면 이전 화면으로 돌아갑니다.
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

  /// "검색하기" 버튼을 누르면 선택된 주소의 위도와 경도를 백엔드로 전송합니다.
  Future<void> _sendLocationToBackend() async {
    HapticFeedback.lightImpact();
    final addr = _finalAddressController.text.trim();
    if (addr.isEmpty) {
      HapticFeedback.mediumImpact();
      _showSnackBar('주소를 선택하세요.');
      return;
    }
    try {
      final response = await UniversityService.sendLocationData(
        acr: _selectedLat,
        dwn: _selectedLng,
        page: 0,
      );
      _showSnackBar('위치 전송 성공: ${response.toString()}');
    } catch (e) {
      _showSnackBar('위치 전송 실패: $e');
    }
  }

  /// 검색 뷰를 열기 위해 플래그를 변경합니다.
  void _openSearchView() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSearchView = true;
      _searchController.clear();
      _searchResults.clear();
      _searchCoords.clear();
    });
  }

  /// 입력한 검색어로 주소 검색(여러 결과 및 각 위/경도 정보)을 진행합니다.
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

      // geocoding 결과로부터 placemark 정보를 가져와 주소 문자열로 변환합니다.
      for (final loc in locations) {
        final placemarks =
            await placemarkFromCoordinates(loc.latitude, loc.longitude);
        for (final place in placemarks) {
          final addr = _formatPlacemark(place);
          if (addr.isNotEmpty && !foundNames.contains(addr)) {
            foundNames.add(addr);
            foundCoords.add(Offset(loc.latitude, loc.longitude));
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

  /// GPS를 이용하여 현재 위치 기반으로 주소 검색을 진행합니다.
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
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);

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

  /// 검색 결과의 특정 인덱스를 선택하면 메인 화면의 주소 필드와 위/경도 값이 업데이트됩니다.
  void _onSelectResultIndex(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _finalAddressController.text = _searchResults[index];
      _selectedLat = _searchCoords[index].dx;
      _selectedLng = _searchCoords[index].dy;
      _isSearchView = false;
    });
  }

  /// Placemark 객체를 받아 적절한 주소 문자열로 변환합니다.
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
            // 메인 뷰와 검색 뷰를 AnimatedSwitcher로 전환합니다.
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSearchView ? _buildSearchView() : _buildMainView(),
              ),
            ),
            // 왼쪽 상단의 뒤로가기/닫기 아이콘
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

  /// 메인 뷰: 선택된 주소(읽기 전용 텍스트필드)와 검색, "검색하기" 버튼 구성
  Widget _buildMainView() {
    return Container(
      key: const ValueKey('MainView'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Center(
        child: Column(
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
                    child: const Icon(Icons.gps_fixed, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // "검색하기" 버튼이 눌리면 선택된 주소의 위/경도 정보를 백엔드로 전송합니다.
            ElevatedButton(
              onPressed: _sendLocationToBackend,
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
          ],
        ),
      ),
    );
  }

  /// 검색 뷰: 검색어 입력, 주소 검색, GPS 기반 검색, 그리고 검색 결과 목록
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

  /// 검색 결과 목록 (리스트뷰). 각 결과를 선택하면 _onSelectResultIndex가 호출됩니다.
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
