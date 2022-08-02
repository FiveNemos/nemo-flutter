import 'package:flutter/material.dart';
import '../../providers/bottomBar.dart';
import 'chat_list_page.dart';
import 'package:provider/provider.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold for route message page
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NeMo',
          style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ChatPage(),
      // bottomnavigatonbar for rotue to the main page -> contacts, sharing, message, mypage
      bottomNavigationBar: context
          .read<BottomNavigationProvider>()
          .bottomNavigationBarClick(3, context),
    );
  }

  // bottomNavigationBarClick(nowIndex, context) {
  //   return BottomNavigationBar(
  //       type: BottomNavigationBarType.fixed,
  //       items: [
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.contacts),
  //           label: '연락처',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.map),
  //           label: '지도',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.share),
  //           label: '공유',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.message),
  //           label: '메시지',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.person),
  //           label: '마이페이지',
  //         ),
  //       ],
  //       currentIndex: nowIndex,
  //       onTap: (int nextIndex) {
  //         if (nextIndex == nowIndex && nextIndex != 1) {
  //           return;
  //         }
  //         switch (nextIndex) {
  //           case 0:
  //             Navigator.pushNamed(context, '/contacts');
  //             break;
  //           case 1:
  //             Navigator.pushNamed(context, '/sharing');
  //             break;
  //           case 2:
  //             Navigator.pushNamed(context, '/map');
  //             break;
  //           case 3:
  //             Navigator.pushNamed(context, '/message');
  //             break;
  //           case 4:
  //             Navigator.pushNamed(context, '/mypage');
  //             break;
  //         }
  //       });
  // }
}
