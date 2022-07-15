import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/mypage/user.dart';
import '../../tests/mypage/preferences.dart';
import '../../widgets/mypage/profile_widget.dart';
import '../message/chat_detail_page.dart';

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
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20), // 전체 박스에 대한 padding
          itemCount: buildList.length,
          itemBuilder: (context, i) {
            return buildList[i](user);
          },
          separatorBuilder: (context, i) => SizedBox(height: 15),
        ));

    // return Scaffold(
    //     appBar: AppBar(),
    //     body: ListView.separated(
    //       // shrinkWrap: true,
    //       physics: BouncingScrollPhysics(),
    //       scrollDirection: Axis.vertical,
    //       padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
    //       itemCount: buildList.length,
    //       itemBuilder: (context, i) {
    //         return buildList[i](user);
    //       },
    //       separatorBuilder: (context, i) => SizedBox(height: 15),
    //     ));
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ChatDetailPage(
                        name: user.nickname,
                        imageUrl: user.imagePath,
                      );
                    }));
                  },
                  icon: Icon(
                    Icons.send,
                    color: Colors.purple,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user.introduction,
            style: TextStyle(color: Colors.grey, fontSize: 18),
          )
        ],
      );

  Widget buildImageTag(UserProfile user) => Align(
        alignment: Alignment.center,
        child: Container(
          width: double.infinity,
          alignment: Alignment.topCenter,
          // color: Colors.red,
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            // padding:
            //     EdgeInsets.fromLTRB(10, 10, 10, 10), // 추가적인 padding을 줄 경우에 사용
            itemCount: user.image.length,
            itemBuilder: (c, i) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ]);
            },
            separatorBuilder: (c, j) => SizedBox(width: 25),
          ),
        ),
      );

  Widget buildAbout(UserProfile user) => Container(
        // color: Colors.blue,
        // padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 문장의 시작점
          children: [
            Text(
              user.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              user.about,
              style: TextStyle(
                  fontSize: 17, height: 1.5), // height가 자간? 다른 방법 있었던듯
            ),
          ],
        ),
      );
}
