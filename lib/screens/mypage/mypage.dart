import 'package:flutter/material.dart';
import 'profile_page.dart';

class MypagePage extends StatefulWidget {
  const MypagePage({Key? key}) : super(key: key);

  @override
  State<MypagePage> createState() => _MypagePageState();
}

class _MypagePageState extends State<MypagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfilePage(
        friendId: null,
        currIndex: 4,
      ), // mypage니까 friendID = null
    );
  }
}
