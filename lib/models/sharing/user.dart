class User {
  final int user_id;
  final String tag_1;
  final String tag_2;
  final String tag_3;
  final String nickname;
  final String intro;
  final String image;

  const User({
    required this.user_id,
    required this.tag_1,
    required this.tag_2,
    required this.tag_3,
    required this.nickname,
    required this.intro,
    required this.image,
  });

  User.fromJson(Map<dynamic, dynamic> json)
      : user_id = json['user_id'],
        tag_1 = json['tag_1'],
        tag_2 = json['tag_2'],
        tag_3 = json['tag_3'],
        nickname = json['nickname'],
        intro = json['intro'],
        image = json['image'];

  Map<String, dynamic> toJson() => {
        'user_id': user_id,
        'tag_1': tag_1,
        'tag_2': tag_2,
        'tag_3': tag_3,
        'nickname': nickname,
        'intro': intro,
        'image': image,
      };
}
