import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationItem {
  final String notiId;
  final String title;
  final String content;
  final DateTime dueDate;
  final String id;

  NotificationItem({
    required this.notiId,
    required this.title,
    required this.content,
    required this.dueDate,
    required this.id,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      notiId: json['notiId'].toString(),
      title: json['title'],
      content: json['content'],
      dueDate: DateTime.parse(json['dueDate']),
    );
  }
}

class CollegeReminderScreen extends StatefulWidget {
  const CollegeReminderScreen({super.key});

  @override
  _CollegeReminderScreenState createState() => _CollegeReminderScreenState();
}

class _CollegeReminderScreenState extends State<CollegeReminderScreen> {
  List<NotificationItem> _notifications = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // 타임존 초기화 (필수)
    tz.initializeTimeZones();
    //_initializeNotifications();
    _fetchNotifications();
  }

  // flutter_local_notifications 초기화
  // Future<void> _initializeNotifications() async {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(android: initializationSettingsAndroid);
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  // 백엔드에서 알림 데이터를 가져오는 함수
  Future<void> _fetchNotifications() async {
    final url =
        Uri.parse("https://your-backend.com/api/notifications/{id}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _notifications =
              data.map((json) => NotificationItem.fromJson(json)).toList();
        });
        // 각 알림에 대해 기한 전날 푸시 알림 예약
        // for (var notification in _notifications) {
        //   _scheduleNotification(notification);
        // }
      } else {
        print("알림을 가져오는 중 오류 발생: ${response.statusCode}");
      }
    } catch (e) {
      print("알림 데이터를 가져오는 중 예외 발생: $e");
    }
  }

  // 알림 삭제 함수: 백엔드에 삭제 요청 후 리스트에서 제거 및 예약 알림 취소
  Future<void> _deleteNotification(NotificationItem notification) async {
    final url = Uri.parse(
        "https://your-backend.com/api/notifications/${notification.notiId}");
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _notifications.remove(notification);
        });
        // 예약된 푸시 알림 취소 (ID를 hashCode로 사용)
        await flutterLocalNotificationsPlugin
            .cancel(notification.notiId.hashCode);
      } else {
        print("알림 삭제 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("알림 삭제 중 예외 발생: $e");
    }
  }

  // 기한 전날에 푸시 알림을 예약하는 함수 (zonedSchedule() 사용)
  // Future<void> _scheduleNotification(NotificationItem notification) async {
  //   final scheduledDate =
  //       notification.dueDate.subtract(const Duration(days: 1));
  //   if (scheduledDate.isAfter(DateTime.now())) {
  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //       notification.id.hashCode, // 고유 식별자로 hashCode 사용
  //       notification.title,
  //       notification.content,
  //       tz.TZDateTime.from(scheduledDate, tz.local),
  //       const NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           'reminder_channel',
  //           'Reminder Notifications',
  //           channelDescription: '기한 임박 알림을 전달합니다.',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //         ),
  //       ),
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "대학 알림",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        ),
      ),
      body: _notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      notification.title,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.content,
                          style: const TextStyle(fontSize: 25),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "기한: ${notification.dueDate.toLocal().toString().split(' ')[0]}",
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 20),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _deleteNotification(notification);
                      },
                      child: const Text(
                        "완료",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
