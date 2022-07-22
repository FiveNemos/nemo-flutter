import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// import 'dart:convert'; // json decode 등등 관리
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nemo_flutter/screens/init/login.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:nemo_flutter/screens/mypage/profile_page.dart';
// import '../../tests/contacts/preferences.dart';

class InitPage extends StatefulWidget {
  const InitPage({Key? key}) : super(key: key);

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';

  checkUserState() async {
    if (await isLogined() == false) {
      Navigator.pushNamed(context, '/login');
    } else if (await findCard(userInfo['user_id']) == false) {
      Navigator.pushNamed(context, '/namecard');
    } else {
      Navigator.pushNamed(context, '/contacts');
    }
  }

  emergency() async {
    Navigator.pushNamed(context, '/login');
  }

  isLogined() async {
    print('isLogined start');
    userInfo = await storage.read(key: 'login');
    if (userInfo == null) {
      return false;
    } else {
      userInfo = jsonDecode(userInfo);
      print(userInfo['user_id']);
      return true;
    }
  }

  findCard(id) async {
    try {
      var dio = Dio();
      Response response = await dio.get('http://34.64.217.3:3000/api/card/$id');
      if (response.data.runtimeType != bool) {
        return true;
      } else {
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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   checkUserState();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              checkUserState();
            },
            onDoubleTap: () {
              emergency();
            },
            child: Image.asset(
              'assets/common/logo.png',
              alignment: Alignment.center,
              height: 400,
            ),
          ),
          Text(
            'NEMO 를 눌러주세요! ',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xff8338EC)),
          ),
        ],
      ),
    );
  }
}
