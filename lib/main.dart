import 'package:flutter/material.dart';

// import initial page
import 'screens/init/login.dart';
import 'screens/init/signup.dart';

// import 'pages/newNameCard.dart';
import 'screens/contacts/contacts.dart';

import 'screens/message/message.dart';
import 'screens/mypage/mypage.dart';
import 'screens/sharing/sharing.dart';
import 'screens/setting/setting.dart';

// name card page
import 'screens/mypage/mypage_generator.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/contacts': (context) => ContactsPage(),
        '/message': (context) => MessagePage(),
        '/mypage': (context) => MypagePage(),
        '/sharing': (context) => SharingPage(),
        '/setting': (context) => SettingPage(),
        '/namecard': (context) => NameCardGenerator(),
      }, // end routes
    );
  }
}
