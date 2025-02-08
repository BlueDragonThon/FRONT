// university_widgets.dart
import 'package:bluedragonthon/utils/university_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityListItem extends StatelessWidget {
  final University university;
  final VoidCallback onToggleHeart;

  const UniversityListItem({
    super.key,
    required this.university,
    required this.onToggleHeart,
  });

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          university.name,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // 전화번호 터치 시 전화 앱으로 연결
            InkWell(
              onTap: () async {
                final String phoneNumber =
                    university.contactInfo.replaceAll('-', '');
                final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
                await _launchUrl(telUri);
              },
              child: Text(
                university.contactInfo,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              university.address,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              '프로그램: ${university.program.join(", ")}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            university.isHeart ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
            size: 30,
          ),
          onPressed: onToggleHeart,
        ),
      ),
    );
  }
}
