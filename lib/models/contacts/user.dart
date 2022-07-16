import 'dart:convert';

class User {
  final String imagePath;
  final String nickname;
  final String introduction;
  final List<String> tag;

  const User({
    required this.imagePath,
    required this.nickname,
    required this.introduction,
    required this.tag,
  });
}
