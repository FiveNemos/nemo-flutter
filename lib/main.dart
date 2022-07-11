import 'package:flutter/material.dart';

// import initial page
import 'pages/init/login.dart';
import 'pages/init/signup.dart';

// import 'pages/newNameCard.dart';
import 'pages/main/contacts/contacts.dart';
import 'pages/main/message/message.dart';
import 'pages/main/mypage/mypage.dart';
import 'pages/main/sharing/sharing.dart';
import 'pages/main/setting/setting.dart';

// name card page
import 'pages/namecard/generator.dart';

// --------------------------------------------------

void main() => runApp(MaterialApp(
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
    ));
