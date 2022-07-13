import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../contacts/model/user.dart';
import '../contacts/utils/user_preferences.dart';
import '../contacts/utils/user_preferences2.dart';
import '../contacts/utils/user_preferences3.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final user = UserPreferences.myUser;
  final us3r = UserPreferenc2s.m2User;
  final us5r = UserPreferenc3s.m3User;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: InkWell(
                onTap: () => print("test"),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // add this
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      child: Image.network(us3r.imagePath,
                          width: 300, height: 280, fit: BoxFit.fill),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(us3r.nickname,
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      subtitle: Text(us3r.introduction,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/mypage');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // add this
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      child: Image.network(user.imagePath,
                          width: 300, height: 280, fit: BoxFit.fill),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(user.nickname,
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      subtitle: Text(user.introduction,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/mypage');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // add this
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      child: Image.network(us5r.imagePath,
                          width: 300, height: 280, fit: BoxFit.fill),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(us5r.nickname,
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      subtitle: Text(us5r.introduction,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: '연락처',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: '공유',
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
        currentIndex: 0,
        fixedColor: Colors.blue,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/contacts');
              break;
            case 1:
              Navigator.pushNamed(context, '/sharing');
              break;
            case 2:
              Navigator.pushNamed(context, '/message');
              break;
            case 3:
              Navigator.pushNamed(context, '/mypage');
              break;
          }
        },
      ),
    );
  }
}
