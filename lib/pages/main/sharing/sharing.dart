import 'package:flutter/material.dart';
import './screens/tookPage.dart';

class SharingPage extends StatelessWidget {
  const SharingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOOK 페이지'),
      ),
      body: TookPage(),
      // bottomnavigatonbar for rotue to the main page -> contacts, sharing, message, mypage
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
        currentIndex: 1,
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
