import 'package:flutter/material.dart';
// import 'nearby.dart';
import 'merge.dart';

class NotUsed extends StatelessWidget {
  const NotUsed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOOK 페이지'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/namecard');
            },
          ),
        ],
      ),
      body: TookPage(), // redirect to merge.dart
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
              Navigator.pushNamed(context, '/setting');
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
