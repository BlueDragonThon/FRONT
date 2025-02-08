import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluedragonthon/services/api_service.dart';
import 'package:bluedragonthon/utils/token_manager.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MobileLikeUnivListScreen extends StatefulWidget {
  const MobileLikeUnivListScreen({Key? key}) : super(key: key);

  @override
  State<MobileLikeUnivListScreen> createState() => _MobileLikeUnivListScreenState();
}

class _MobileLikeUnivListScreenState extends State<MobileLikeUnivListScreen> {
  bool _isLargeText = false;

  // 찜한 대학 목록
  List<LikeUnivItem> _likeUnivs = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // 페이지(필요 시)
  int _currentPage = 1;
  int _totalPages = 1; // 서버에서 pageCount 받아오면 사용

  @override
  void initState() {
    super.initState();
    _loadLargeTextSetting();
    _fetchLikeUnivs(page: _currentPage);
  }

  // --------------------
  // "큰 글자 모드" 로드
  // --------------------
  Future<void> _loadLargeTextSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLargeText = prefs.getBool('isLargeText') ?? false;
    });
  }

  // --------------------
  // "큰 글자 모드" 저장
  // --------------------
  Future<void> _saveLargeTextSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLargeText', value);
  }

  // --------------------
  // 찜한 대학 목록 불러오기
  // --------------------
  Future<void> _fetchLikeUnivs({required int page}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await ApiService.getLikeUnivList(page);
      setState(() {
        _likeUnivs = response.result.result;
        _totalPages = response.result.pageCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // --------------------
  // 찜 해제(삭제)
  // --------------------
  Future<void> _deleteLikeUniv(int collegeId) async {
    try {
      await ApiService.deleteLikeUniv(collegeId);
      // 서버에서 성공 응답을 받으면 목록에서 제거
      setState(() {
        _likeUnivs.removeWhere((item) => item.id == collegeId);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double labelFontSize = _isLargeText ? 30 : 22;

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // 상단: 큰 글자 스위치
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: labelFontSize,
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
                      _saveLargeTextSetting(value);
                    },
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.blueAccent,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 10),

              // 메인 컨텐츠
              Expanded(
                child: _buildContentArea(),
              ),

              // 아래쪽: 뒤로가기 버튼
              _buildBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _errorMessage,
            style: TextStyle(
              fontSize: _isLargeText ? 26 : 18,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_likeUnivs.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _fetchLikeUnivs(page: _currentPage),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Text(
                    '찜한 대학이 없습니다.',
                    style: TextStyle(fontSize: _isLargeText ? 26 : 18),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchLikeUnivs(page: _currentPage),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _likeUnivs.length,
        itemBuilder: (context, index) {
          final univItem = _likeUnivs[index];
          return _NeumorphicLikeUnivCard(
            univItem: univItem,
            isLargeText: _isLargeText,
            onDelete: () => _deleteLikeUniv(univItem.id),
          );
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final double buttonHeight = 70;
    final double buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final double iconSize = _isLargeText ? 32 : 24;
    final double textSize = _isLargeText ? 28 : 20;

    const baseColor = Color(0xFFE3E5ED);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pop(context);
        },
        child: Container(
          height: buttonHeight,
          width: buttonWidth,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(6, 6),
                blurRadius: 20,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.9),
                offset: const Offset(-6, -6),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: iconSize),
              const SizedBox(width: 8),
              Text(
                '뒤로가기',
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 뉴모피즘 카드 (하트 아이콘 사용)
class _NeumorphicLikeUnivCard extends StatelessWidget {
  final LikeUnivItem univItem;
  final bool isLargeText;
  final VoidCallback onDelete;

  const _NeumorphicLikeUnivCard({
    Key? key,
    required this.univItem,
    required this.isLargeText,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFFE3E5ED);
    final double contentFontSize = isLargeText ? 26.0 : 18.0;
    final double iconSize = contentFontSize + 8;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(6, 6),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: const Offset(-6, -6),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 대학 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  univItem.name,
                  style: TextStyle(
                    fontSize: contentFontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '총장: ${univItem.headmaster}',
                  style: TextStyle(fontSize: contentFontSize),
                ),
                Text(
                  '연락처: ${univItem.contactInfo}',
                  style: TextStyle(fontSize: contentFontSize),
                ),
                Text(
                  '주소: ${univItem.address}',
                  style: TextStyle(fontSize: contentFontSize),
                ),
                const SizedBox(height: 8),
                Text(
                  '개설 프로그램: ${univItem.program.join(", ")}',
                  style: TextStyle(fontSize: contentFontSize),
                ),
                const SizedBox(height: 8),
                // 필요하면 상태 표시 문구
                // Text(
                //   univItem.favorites ? '★ 찜한 상태' : '찜 해제됨',
                //   style: TextStyle(
                //     fontSize: contentFontSize,
                //     color: univItem.favorites ? Colors.blue : Colors.grey,
                //   ),
                // ),
              ],
            ),
          ),
          // 오른쪽: 하트 아이콘 (채워진 상태 → 누르면 삭제)
          Container(
            margin: const EdgeInsets.only(left: 10),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                // 하트가 채워진 상태에서 누르면 '삭제' 로직 수행
                HapticFeedback.lightImpact();
                onDelete();
              },
              child: Icon(
                Icons.favorite,
                size: iconSize,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
