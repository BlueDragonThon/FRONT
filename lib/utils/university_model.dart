import 'dart:ffi';

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
      id: json['id'] as int,
      name: json['name'] as String,
      contactInfo: json['contactInfo'] as String,
      address: json['address'] as String,
      isHeart: json['isHeart'] ?? false, // null이면 false 할당
      program: (json['program'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
