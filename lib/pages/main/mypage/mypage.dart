import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mypage/page/profile_page.dart';

import '../message/message.dart';
import '../message/screens/chatDetailPage.dart';
import '../message/stores/storeMessage.dart';
import '../message/models/chatMessageModel.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MypagePage extends StatefulWidget {
  const MypagePage({Key? key}) : super(key: key);

  @override
  State<MypagePage> createState() => _MypagePageState();
}

class _MypagePageState extends State<MypagePage> {
  getData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailPage(
                    name: "정글러버",
                    imageUrl:
                        "https://s3.us-west-2.amazonaws.com/secure.notion-static.com/668a3935-3fcd-4bd5-a419-4cb7732a5288/KakaoTalk_Photo_2022-07-04-01-01-40.gif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220712%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220712T140031Z&X-Amz-Expires=86400&X-Amz-Signature=a9a591296e62e42bcb75d5a32f4082bd6e07239b04e544de79f36390268f7be8&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22KakaoTalk_Photo_2022-07-04-01-01-40.gif%22&x-id=GetObject",
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: MyProfile(),
    );
  }
}

class MyProfile extends StatelessWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue.shade300,
        dividerColor: Colors.black,
      ),
      home: ProfilePage(),
    );
  }
}
