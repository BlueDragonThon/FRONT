import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluedragonthon/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileLectureReviewCreateScreen extends StatefulWidget {
  final bool isLargeText;

  const MobileLectureReviewCreateScreen({
    Key? key,
    required this.isLargeText,
  }) : super(key: key);

  @override
  State<MobileLectureReviewCreateScreen> createState() => _MobileLectureReviewCreateScreenState();
}

class _MobileLectureReviewCreateScreenState extends State<MobileLectureReviewCreateScreen> {
  late bool _isLargeText;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _isLargeText = widget.isLargeText; // 이전 화면의 설정 이어받기
  }

  // SharedPreferences에 큰 글씨 모드 저장
  Future<void> _saveLargeTextSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLargeText', value);
  }

  // 리뷰 작성
  Future<void> _createReview() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() {
        _errorMessage = '제목과 내용을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await ApiService.createReview(title, content);
      Navigator.pop(context); // 작성 후 돌아가기
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double labelFontSize = _isLargeText ? 26 : 20;
    final double textFieldFontSize = _isLargeText ? 24 : 16;

    return Scaffold(
      appBar: AppBar(
        title: Text('리뷰 작성', style: TextStyle(fontSize: labelFontSize)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: labelFontSize),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Text(
              '큰 글자',
              style: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: _isLargeText,
            onChanged: (value) {
              setState(() {
                _isLargeText = value;
              });
              _saveLargeTextSetting(value);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        // 배경 그라디언트
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3E5ED),
              Color(0xFFDADCE2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 스크롤 영역
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_errorMessage.isNotEmpty) ...[
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: _isLargeText ? 24 : 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildNeumorphicTextField(
                      controller: _titleController,
                      label: '제목',
                      fontSize: textFieldFontSize,
                    ),
                    const SizedBox(height: 16),
                    _buildNeumorphicTextField(
                      controller: _contentController,
                      label: '내용',
                      fontSize: textFieldFontSize,
                      maxLines: 8,
                    ),
                    const SizedBox(height: 100), // 하단 버튼 공간 확보
                  ],
                ),
              ),
              // 로딩 인디케이터
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),

              // 하단 고정: "등록하기" 버튼
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: _buildCreateButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 뉴모피즘 스타일의 TextField 래퍼
  Widget _buildNeumorphicTextField({
    required TextEditingController controller,
    required String label,
    required double fontSize,
    int maxLines = 1,
  }) {
    const baseColor = Color(0xFFE3E5ED);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }

  /// 하단 "등록하기" 뉴모피즘 버튼
  Widget _buildCreateButton() {
    final double buttonHeight = 60;
    final double buttonWidth = MediaQuery.of(context).size.width * 0.8;
    final double iconSize = _isLargeText ? 28 : 22;
    final double textSize = _isLargeText ? 24 : 18;
    const baseColor = Color(0xFFE3E5ED);

    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _createReview();
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
              Icon(Icons.check, size: iconSize),
              const SizedBox(width: 8),
              Text(
                '등록하기',
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
