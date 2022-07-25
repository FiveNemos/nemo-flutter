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
      appBar: AppBar(
        title: Text(
          'Nemo',
          style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'logout',
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
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
    return ProfilePage(); // 여기에 id 넘겨주기
  }
}
