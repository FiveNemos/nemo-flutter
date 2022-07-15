import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/mypage/user.dart';
import '../../tests/mypage/preferences.dart';
import '../../widgets/mypage/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, this.nickname}) : super(key: key);
  var nickname;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    // final user = UserPreferences.myUser;
    var user = UserProfiles[widget.nickname];
    List buildList = [
      buildAvatar,
      buildName,
      buildImageTag,
      buildAbout,
    ];
    List tagList = [
      buildAvatar,
      buildName,
      buildImageTag,
      buildAbout,
    ];

    return Scaffold(
        appBar: AppBar(),
        body: ListView.separated(
          // shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
          itemCount: buildList.length,
          itemBuilder: (context, i) {
            return buildList[i](user);
          },
          separatorBuilder: (context, i) => SizedBox(height: 15),
        ));
  }

  Widget buildAvatar(UserProfile user) => ProfileWidget(
        imagePath: user.imagePath,
        onClicked: () async {},
      );

  Widget buildName(UserProfile user) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.nickname,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
              Text("DM버튼"),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user.introduction,
            style: TextStyle(color: Colors.grey, fontSize: 20),
          )
        ],
      );

  Widget buildAbout(UserProfile user) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              user.about,
              style: TextStyle(fontSize: 20, height: 1.4),
            ),
          ],
        ),
      );
}

Widget buildImageTag(UserProfile user) => SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
        itemCount: user.image.length,
        itemBuilder: (c, i) {
          return Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                // user.image1,
                user.image[i],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              user.tag[i],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ]);
        },
        separatorBuilder: (c, j) => SizedBox(width: 10),
      ),
    );
