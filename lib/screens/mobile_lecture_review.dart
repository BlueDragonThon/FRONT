import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluedragonthon/services/api_service.dart';
import 'package:bluedragonthon/utils/token_manager.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'mobile_lecture_review_create.dart'; // 풀스크린 작성 페이지

class MobileLectureReviewScreen extends StatefulWidget {
  const MobileLectureReviewScreen({super.key});

  @override
  State<MobileLectureReviewScreen> createState() =>
      _MobileLectureReviewScreenState();
}

class _MobileLectureReviewScreenState extends State<MobileLectureReviewScreen> {
  bool _isLargeText = false; // 큰 글씨 모드
  List<ReviewItem> _reviews = []; // 리뷰 목록
  bool _isLoading = false; // 로딩 중 여부
  String _errorMessage = ''; // 에러 메시지

  @override
  void initState() {
    super.initState();
    _loadLargeTextSetting();
    _fetchReviews();
  }

  Future<void> _loadLargeTextSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLargeText = prefs.getBool('isLargeText') ?? false;
    });
  }

  Future<void> _saveLargeTextSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLargeText', value);
  }

  /// 리뷰 목록 불러오기 (Read)
  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final reviews = await ApiService.getReviews();
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 리뷰 삭제
  Future<void> _deleteReview(int reviewId) async {
    try {
      await ApiService.deleteReview(reviewId);
      setState(() {
        _reviews.removeWhere((r) => r.id == reviewId);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  /// 리뷰 수정 (팝업)
  Future<void> _updateReview(ReviewItem review, String newTitle,
      String newProgram, String newContent) async {
    try {
      await ApiService.updateReview(
          review.id, newTitle, newProgram, newContent);
      await _fetchReviews();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  /// 리뷰 수정 다이얼로그
  void _showUpdateDialog(ReviewItem review) {
    final univController = TextEditingController(text: review.university);
    final programController = TextEditingController(text: review.program);
    final contentController = TextEditingController(text: review.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text('리뷰 수정', style: TextStyle(fontSize: _isLargeText ? 26 : 20)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: univController,
                  decoration: const InputDecoration(labelText: '학교'),
                  style: TextStyle(fontSize: _isLargeText ? 24 : 16),
                ),
                TextField(
                  controller: programController,
                  decoration: const InputDecoration(labelText: '프로그램'),
                  style: TextStyle(fontSize: _isLargeText ? 24 : 16),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: '내용'),
                  style: TextStyle(fontSize: _isLargeText ? 24 : 16),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('취소',
                  style: TextStyle(fontSize: _isLargeText ? 22 : 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('수정',
                  style: TextStyle(fontSize: _isLargeText ? 22 : 16)),
              onPressed: () async {
                final newTitle = univController.text.trim();
                final newProgram = programController.text.trim();
                final newContent = contentController.text.trim();
                if (newTitle.isNotEmpty &&
                    newContent.isNotEmpty &&
                    newProgram.isNotEmpty) {
                  await _updateReview(review, newTitle, newProgram, newContent);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// 풀스크린으로 "리뷰 작성" 페이지로 이동
  Future<void> _navigateToCreateReviewScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MobileLectureReviewCreateScreen(isLargeText: _isLargeText),
      ),
    );
    // 작성 후 돌아오면 자동 리프레시
    _fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    final double labelFontSize = _isLargeText ? 30 : 23;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 55),
          onPressed: () => Navigator.pop(context),
        ),
        //title: Text('수강 후기', style: TextStyle(fontSize: labelFontSize)),
        backgroundColor: Color(0xFFE3E5ED),
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
          child: Column(
            children: [
              Expanded(child: _buildContentArea()),
              // 하단: "리뷰 작성하기" 뉴모피즘 버튼
              _buildCreateReviewButton(context),
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
          padding: const EdgeInsets.all(16.0),
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
    if (_reviews.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchReviews,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),
            Center(
              child: Text(
                '아직 등록된 리뷰가 없습니다.',
                style: TextStyle(fontSize: _isLargeText ? 26 : 18),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchReviews,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return _NeumorphicReviewCard(
            review: review,
            isLargeText: _isLargeText,
            onDelete: () => _deleteReview(review.id),
            onEdit:
                review.isUserCreated ? () => _showUpdateDialog(review) : null,
          );
        },
      ),
    );
  }

  /// "리뷰 작성하기" 버튼 (뉴모피즘)
  Widget _buildCreateReviewButton(BuildContext context) {
    final double buttonHeight = 60;
    final double buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final double iconSize = _isLargeText ? 28 : 22;
    final double textSize = _isLargeText ? 24 : 18;
    const baseColor = Color(0xffB3A3EC);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _navigateToCreateReviewScreen();
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
                Icon(
                  Icons.add,
                  size: iconSize,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  '리뷰 작성하기',
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

/// 뉴모피즘 스타일의 리뷰 카드
class _NeumorphicReviewCard extends StatelessWidget {
  final ReviewItem review;
  final bool isLargeText;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const _NeumorphicReviewCard({
    super.key,
    required this.review,
    required this.isLargeText,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFFE3E5ED);
    final double contentFontSize = isLargeText ? 24 : 16;

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
          // 왼쪽: 제목/내용/작성자
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.university,
                  style: TextStyle(
                    fontSize: contentFontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review.program,
                  style: TextStyle(fontSize: contentFontSize),
                ),
                const SizedBox(height: 8),
                Text(
                  review.content,
                  style: TextStyle(fontSize: contentFontSize),
                ),
                const SizedBox(height: 8),
                Text(
                  '작성자: ${review.writer}',
                  style: TextStyle(
                    fontSize: contentFontSize - 2,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          // 오른쪽: 수정(옵션) + 삭제
          if (review.isUserCreated) ...[
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit,
                  color: Colors.blue, size: contentFontSize + 6),
            ),
          ],
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete,
                color: Colors.red, size: contentFontSize + 6),
          ),
        ],
      ),
    );
  }
}
