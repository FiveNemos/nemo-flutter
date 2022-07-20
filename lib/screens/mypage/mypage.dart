import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MypagePage extends StatefulWidget {
  const MypagePage({Key? key}) : super(key: key);

  @override
  State<MypagePage> createState() => _MypagePageState();
}

class _MypagePageState extends State<MypagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Profile'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.send),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => ChatDetailPage(
      //               name: "정글러버",
      //               imageUrl: "http://34.64.217.3:3000/static/junglelover.gif",
      //             ),
      //           ),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: MyProfile(),
    );
  }
}

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  var id;
  saveData() async {
    var storage = await SharedPreferences.getInstance();
    setState(() {
      id = storage.getInt('id');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(nickname: '고니고니'); // 여기에 id 넘겨주기
  }
}
