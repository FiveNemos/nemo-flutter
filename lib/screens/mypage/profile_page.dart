import 'package:flutter/material.dart';

import '../../models/mypage/user.dart';
import '../../tests/mypage/preferences.dart';
import '../../widgets/mypage/profile_widget.dart';
import '../message/chat_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, this.nickname}) : super(key: key);
  var nickname;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var id;
  var user;
  saveData() async {
    var storage = await SharedPreferences.getInstance();
    setState(() {
      id = storage.getInt('id');
    });
    getMyCard(id);
  }

  getMyCard(id) async {
    print('http://34.64.217.3:3000/api/card/$id');
    try {
      var dio = Dio();
      Response response = await dio.get('http://34.64.217.3:3000/api/card/$id');
      // Response response2 = await dio.get('http://34.64.217.3:3000/api/card/99'); // 실험

      if (response.statusCode == 200) {
        final json = response.data;
        setState(() {
          user = UserProfile(
            imagePath: json['img_url'],
            nickname: json['nickname'],
            introduction: json['intro'],
            title: json['intro'], // title로 변경 필요
            about: json['intro'], // about로 변경 필요
            image1:
                'https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1780&q=80',
            image2:
                'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1548&q=80',
            image3: 'https://wallpaperaccess.com/full/1935243.jpg',
            tag1: json['tag_1'],
            tag2: json['tag_2'],
            tag3: json['tag_3'],
            image: [
              'https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1780&q=80',
              'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1548&q=80',
              'https://wallpaperaccess.com/full/1935243.jpg',
            ], // tag_image로 변경이 필요
            tag: [
              json['tag_1'],
              json['tag_2'],
              json['tag_3'],
            ],
          );
        });
        print('접속 성공!');
        print('json : $json');
        print(json['img_url']);
        print(json['img_url'].runtimeType);
        // /* 여기부턴 실험중 */
        // final json2 = response2.data;
        // var result = json2['tag_1'];
        // print("json2: ${result}");
        // print(result.runtimeType);
        // List result2 = result.split(' ');
        // // result2.remove , result2.add
        // String json3 = result2.join(' ');
        // print("here");
        // print("result2: $result2");
        // print(result2.runtimeType);
        // var string1 = '1658212922913-image_picker855487046303368457.png';
        // print(string1.length);

        // print('jsonBody : $jsonBody');
        return true;
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    // final user = UserPreferences.myUser;
    // var user = UserProfiles[widget.nickname];
    List buildList = [
      buildAvatar,
      buildName,
      buildImageTag,
      buildAbout,
    ];
    if (user != null) {
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
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      );
    }
  }

  Widget buildAvatar2(UserProfile user) => ProfileWidget(
        imagePath: user.imagePath,
        onClicked: () async {},
      );

  Widget buildAvatar(UserProfile user) => ProfileWidget(
        imagePath: 'http://34.64.217.3:3000/static/${user.imagePath}',
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
