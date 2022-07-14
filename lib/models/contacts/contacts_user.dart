import 'dart:convert';

class User {
  final String imagePath;
  final String nickname;
  final String introduction;

  const User({
    required this.imagePath,
    required this.nickname,
    required this.introduction,
  });
}
