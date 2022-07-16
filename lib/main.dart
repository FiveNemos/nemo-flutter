import 'package:flutter/material.dart';

// import widget style
import './styles/style.dart' as style;

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
import 'screens/mypage/cardgenerator.dart';

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
      initialRoute: '/contacts',
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
