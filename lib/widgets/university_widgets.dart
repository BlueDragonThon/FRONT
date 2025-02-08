import 'package:bluedragonthon/utils/university_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityListItem extends StatefulWidget {
  final University university;
  final VoidCallback onToggleHeart;

  const UniversityListItem({
    super.key,
    required this.university,
    required this.onToggleHeart,
  });

  @override
  _UniversityListItemState createState() => _UniversityListItemState();
}

class _UniversityListItemState extends State<UniversityListItem> {
  late bool _isHeart;

  @override
  void initState() {
    super.initState();
    _isHeart = widget.university.isHeart;
  }

  @override
  void didUpdateWidget(covariant UniversityListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.university.isHeart != widget.university.isHeart) {
      setState(() {
        _isHeart = widget.university.isHeart;
      });
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          widget.university.name,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  '전화번호',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    final String phoneNumber =
                        widget.university.contactInfo.replaceAll('-', '');
                    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
                    await _launchUrl(telUri);
                  },
                  child: Text(
                    widget.university.contactInfo,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '주소',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.university.address,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 4),
            const Text(
              '프로그램',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.university.program.join(", "),
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            widget.university.isHeart ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
            size: 30,
          ),
          onPressed: widget.onToggleHeart,
        ),
      ),
    );
  }
}
