class University {
  final int id;
  final String name;
  final String contactInfo;
  final String address;
  final List<String> program;
  final bool isHeart;

  University({
    required this.id,
    required this.name,
    required this.contactInfo,
    required this.address,
    required this.program,
    required this.isHeart,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as int,
      name: json['name'] as String,
      contactInfo: json['contactInfo'] as String,
      address: json['address'] as String,

      program: (json['program'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      // 서버 응답에서 "favorites" 라는 boolean
      isHeart: json['favorites'] == true,
    );
  }
}
