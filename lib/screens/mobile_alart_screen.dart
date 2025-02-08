import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluedragonthon/services/api_service.dart';
import 'package:bluedragonthon/utils/token_manager.dart';
import 'dart:async';

class MobileAlertScreen extends StatefulWidget {
  const MobileAlertScreen({Key? key}) : super(key: key);

  @override
  State<MobileAlertScreen> createState() => _MobileAlertScreenState();
}

class _MobileAlertScreenState extends State<MobileAlertScreen> {
  bool _isLargeText = false;

  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final List<NotificationItem> data = await ApiService.getNotifications();
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      await ApiService.deleteNotification(notificationId);
      setState(() {
        _notifications.removeWhere((notif) => notif.id == notificationId);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 기존보다 글자 조금 더 크게
    final double labelFontSize = _isLargeText ? 30 : 22;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3E5ED), // 연한 회색
              Color(0xFFDADCE2), // 조금 더 진한 회색
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

              // 알림 목록/에러/로딩/빈 목록
              Expanded(
                child: _buildContentArea(),
              ),

              // 아래 뉴모피즘 뒤로가기 버튼
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

    if (_notifications.isEmpty) {
      // "등록된 알림이 없습니다." 가운데 표시
      return RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Text(
                    '등록된 알림이 없습니다.',
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
      onRefresh: _fetchNotifications,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _NeumorphicNotificationCard(
            notification: notification,
            isLargeText: _isLargeText,
            onDelete: () => _deleteNotification(notification.id),
          );
        },
      ),
    );
  }

  /// 뉴모피즘 뒤로가기 버튼
  Widget _buildBackButton(BuildContext context) {
    final double buttonHeight = 70; // 살짝 높임
    final double buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final double iconSize = _isLargeText ? 32 : 24;
    final double textSize = _isLargeText ? 28 : 20;

    // 뉴모피즘 메인 배경색
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

/// 뉴모피즘 카드 + 삭제 버튼 (오른쪽 중간, 빨간색, 크게)
class _NeumorphicNotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final bool isLargeText;
  final VoidCallback onDelete;

  const _NeumorphicNotificationCard({
    Key? key,
    required this.notification,
    required this.isLargeText,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 뉴모피즘 배경색
    const baseColor = Color(0xFFE3E5ED);
    // 글자 크기를 조금 더 키우고, 큰글씨 모드에서는 더 크게
    final double contentFontSize = isLargeText ? 26.0 : 18.0;
    final double iconSize = contentFontSize + 8; // 삭제 아이콘 크기

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      // height 제거 → 자동 높이로 늘어남
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
          // 왼쪽: 알림 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: contentFontSize + 2, // 제목은 살짝 더 크게
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.content,
                  style: TextStyle(fontSize: contentFontSize),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.date,
                  style: TextStyle(
                    fontSize: contentFontSize - 2,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // 오른쪽: 삭제 버튼 (중앙 정렬)
          Container(
            margin: const EdgeInsets.only(left: 10),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(4, 4),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(-4, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
