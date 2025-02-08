import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluedragonthon/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileLectureReviewCreateScreen extends StatefulWidget {
  final bool isLargeText;

  const MobileLectureReviewCreateScreen({
    super.key,
    required this.isLargeText,
  });

  @override
  State<MobileLectureReviewCreateScreen> createState() =>
      _MobileLectureReviewCreateScreenState();
}

class _MobileLectureReviewCreateScreenState
    extends State<MobileLectureReviewCreateScreen> {
  late bool _isLargeText;
  final _univController = TextEditingController();
  final _subjectController = TextEditingController();
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
    final univ = _univController.text.trim();
    final program = _subjectController.text.trim();
    final content = _contentController.text.trim();

    if (univ.isEmpty || program.isEmpty || content.isEmpty) {
      setState(() {
        _errorMessage = '내용을 모두 채워주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await ApiService.createReview(univ, program, content);
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
    final double labelFontSize = _isLargeText ? 30 : 23;
    final double textFieldFontSize = _isLargeText ? 30 : 23;

    return Scaffold(
      appBar: AppBar(
        //title: Text('수강 후기', style: TextStyle(fontSize: labelFontSize)),
        backgroundColor: Color(0xFFE3E5ED),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 55),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Text(
              '큰 글자',
              style: TextStyle(
                  fontSize: labelFontSize, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: _isLargeText,
            onChanged: (value) {
              setState(() {
                _isLargeText = value;
              });
              // 스위치가 변경될 때 SharedPreferences에 즉시 저장
              _saveLargeTextSetting(value);
            },
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey,
            activeColor: Colors.white,
            activeTrackColor: Colors.blueAccent,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        // 배경 그라디언트
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // Color(0xFFB3A3EC),
              // Color(0xFFDEDBCA),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        32, // padding(16*2) 고려
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
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
                          controller: _univController,
                          label: '   대학',
                          fontSize: textFieldFontSize,
                        ),
                        const SizedBox(height: 16),
                        _buildNeumorphicTextField(
                          controller: _subjectController,
                          label: '   과목',
                          fontSize: textFieldFontSize,
                        ),
                        const SizedBox(height: 16),
                        _buildNeumorphicTextField(
                          controller: _contentController,
                          label: '   내용',
                          fontSize: textFieldFontSize,
                          maxLines: 10,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),

              // 로딩 인디케이터
              if (_isLoading) const Center(child: CircularProgressIndicator()),

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
    const baseColor = Color.fromARGB(255, 255, 255, 255);

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
    const baseColor = Color(0xffB3A3EC);

    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _createReview();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
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
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check,
                  size: iconSize,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  '등록하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
