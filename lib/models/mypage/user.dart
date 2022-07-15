import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfile {
  final String imagePath;
  final String nickname;
  final String introduction;
  final String title;
  final String about;
  final String image1;
  final String image2;
  final String image3;
  final String tag1;
  final String tag2;
  final String tag3;
  List tag;
  List<String> image;

  UserProfile(
      {required this.imagePath,
      required this.nickname,
      required this.introduction,
      required this.title,
      required this.about,
      required this.image1,
      required this.image2,
      required this.image3,
      required this.tag1,
      required this.tag2,
      required this.tag3,
      required this.tag,
      required this.image});
}

// JSON Parsing
// User.fromJson(Map<String, dynamic> json)
//     : imagePath = json['imagePath'],
//       nickname = json['nickname'],
//       introduction = json['introduction'],
//       about = json['about'],
//       image1 = json['image1'],
//       image2 = json['image2'],
//       image3 = json['image3'],
//       tag1 = json['tag1'],
//       tag2 = json['tag2'],
//       tag3 = json['tag3'];
