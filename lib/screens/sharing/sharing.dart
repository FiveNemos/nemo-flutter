import 'package:flutter/material.dart';
import 'package:nemo_flutter/screens/sharing/nearby.dart';
import 'nearby.dart';
import '../../tests/sharing/test.dart';

class SharingPage extends StatelessWidget {
  const SharingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOOK 페이지'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: new Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/namecard');
            },
          ),
        ],
      ),
      // body: TookPage(),
      body: NearbyConnection(),
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
              Navigator.pushNamed(context, '/nearby');
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
