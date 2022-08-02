// TEMP // FOR PROVIDER // 쓰려면 main.dart에 MultiProvider 적용해야함
import 'package:flutter/material.dart';

class BottomNavigationProvider extends ChangeNotifier {
  bottomNavigationBarClick(nowIndex, context) {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: '연락처',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '지도',
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
        currentIndex: nowIndex,
        onTap: (int nextIndex) {
          if (nextIndex == nowIndex && nextIndex != 2) {
            return;
          }
          switch (nextIndex) {
            case 0:
              Navigator.pushNamed(context, '/contacts');
              break;
            case 1:
              Navigator.pushNamed(context, '/map');
              break;
            case 2:
              Navigator.pushNamed(context, '/sharing');
              break;
            case 3:
              Navigator.pushNamed(context, '/message');
              break;
            case 4:
              Navigator.pushNamed(context, '/mypage');
              break;
          }
        });
  }
}
