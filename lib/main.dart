import 'package:flutter/material.dart';
import 'package:nemo_flutter/screens/sharing/sharing_accept_page.dart';

// import widget style
import './styles/style.dart' as style;

// import initial page
import 'screens/init/init.dart';
import 'screens/init/login.dart';
import 'screens/init/signup.dart';

// import 'pages/newNameCard.dart';
import 'screens/contacts/contacts.dart';

import 'screens/message/message.dart';
import 'screens/mypage/mypage.dart';
import 'screens/sharing/sharing.dart';

// name card page
import 'screens/mypage/cardgenerator.dart';

import 'screens/map/map.dart';
// --------------------------------------------------

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nemo test',
      theme: style.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => InitPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/contacts': (context) => ContactsPage(),
        '/message': (context) => MessagePage(),
        '/mypage': (context) => MypagePage(),
        '/sharing': (context) => SharingPage(),
        '/namecard': (context) => NameCardGenerator(),
        '/map': (context) => CurrentLocationScreen(),
      }, // end routes
    );
  }
}
