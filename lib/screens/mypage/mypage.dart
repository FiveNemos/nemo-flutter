import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mypage_profile_page.dart';

import '../message/message.dart';
import '../message/message_chatDetailPage.dart';
import '../../providers/message/message_store.dart';
import '../../models/message/message_chatMessageModel.dart';

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
                    imageUrl: "http://34.64.217.3:3000/static/junglelover.gif",
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
      home: ProfilePage(),
    );
  }
}
