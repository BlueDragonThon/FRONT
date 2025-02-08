// university_model.dart
class University {
  final int id;
  final String name;
  final String contactInfo;
  final String address;
  final bool isHeart;
  final List<String> program;

  University({
    required this.id,
    required this.name,
    required this.contactInfo,
    required this.address,
    required this.isHeart,
    required this.program,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'],
      name: json['name'],
      contactInfo: json['contactInfo'],
      address: json['address'],
      isHeart: json['isHeart'],
      program: List<String>.from(json['program'] ?? []),
    );
  }
}
