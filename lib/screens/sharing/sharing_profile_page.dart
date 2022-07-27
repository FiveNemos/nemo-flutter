import 'package:flutter/material.dart';

import '../../models/mypage/user.dart';
import '../../widgets/mypage/profile_widget.dart';
import '../message/chat_detail_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

const BASE_URL = 'http://34.64.217.3:3000/static/';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, this.friendId}) : super(key: key);
  var friendId;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  var loginID;
  var user;
  bool _isMe = false;
  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      loginID = int.parse(jsonDecode(userInfo)['user_id']);
    });
    if (widget.friendId != null) {
      getCard(widget.friendId);
      setState(() {
        _isMe = false;
      });
    } else {
      getCard(loginID);
      setState(() {
        _isMe = true;
      });
    }
  }

  getChatRoom(loginID, friendID) async {
    try {
      var dio = Dio();
      Response response = await dio.get(
          'http://34.64.217.3:3000/api/chatroom/enter?id_1=$loginID&id_2=$friendID');
      if (response.statusCode == 200) {
        final jsonData = response.data;
        return jsonData;
      } else {
        print('error');
        return 0;
      }
    } on DioError catch (e) {
      print('뭔가 에러가');
      final errorjson = jsonDecode(e.response.toString());
      print(errorjson);
      return 0;
    }
  }

  getCard(id) async {
    print('http://34.64.217.3:3000/api/card/$id');
    try {
      var dio = Dio();
      Response response = await dio.get('http://34.64.217.3:3000/api/card/$id');
      // Response response2 = await dio.get('http://34.64.217.3:3000/api/card/99'); // 실험

      if (response.statusCode == 200) {
        final json = response.data;
        setState(() {
          user = UserProfile(
            imagePath: json['image'],
            nickname: json['nickname'],
            introduction: json['intro'],
            title: json['detail_title'], // title로 변경 필요
            about: json['detail_content'], // about로 변경 필요
            image1: BASE_URL + json['tag_img_1'],
            image2: BASE_URL + json['tag_img_2'],
            image3: BASE_URL + json['tag_img_3'],
            tag1: json['tag_1'],
            tag2: json['tag_2'],
            tag3: json['tag_3'],
            image: [
              BASE_URL + json['tag_img_1'],
              BASE_URL + json['tag_img_2'],
              BASE_URL + json['tag_img_3'],
            ],
            tag: [
              json['tag_1'],
              json['tag_2'],
              json['tag_3'],
            ],
          );
        });
        print('접속 성공!');
        print('json : $json');
        print(json['image']);
        print(json['image'].runtimeType);
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
    checkUser();
    super.initState();
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
      return WillPopScope(
          onWillPop: () {
            setState(() {});
            return Future.value(false);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'NeMo',
                style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
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
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.contacts),
                  label: '연락처',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.share),
                  label: '공유',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: '메시지',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '마이페이지',
                ),
              ],
              currentIndex: 1,
              onTap: (int index) {
                switch (index) {
                  case 0:
                    Navigator.pushNamed(context, '/contacts');
                    break;
                  case 1:
                    // Navigator.pushNamed(context, '/sharing');
                    break;
                  case 2:
                    Navigator.pushNamed(context, '/map');
                    break;
                  case 3:
                    Navigator.pushNamed(context, '/message');
                    break;
                  case 4:
                    Navigator.pushNamed(context, '/mypage');
                    break;
                }
              },
            ),
          ));
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
              !_isMe
                  ? Transform.rotate(
                      angle: 6,
                      child: IconButton(
                          onPressed: () async {
                            // http 요청해서, chatroomID 찾기 by loginID, friendID
                            // var chatroomID = getHTTP(loginID, friendID)
                            var roomID =
                                await getChatRoom(loginID, widget.friendId);
                            if (!mounted) return;
                            if (int.parse(roomID) > 0) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ChatScreen(
                                  chatroomID: roomID, // chatroomID // 수정필요
                                  loginID: loginID,
                                  friendID: widget.friendId,
                                  friendName: user.nickname,
                                  friendImage: user.imagePath,
                                );
                              }));
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.purple,
                          )),
                    )
                  : SizedBox(
                      width: 1,
                      height: 1,
                    ),
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
