import 'package:flutter/material.dart';

var theme = ThemeData(
  appBarTheme: AppBarTheme(
    color: Color(0xff8338EC), // 0xff + HEX값(AppBar 배경)
    // color: Color.fromRGBO(255, 0, 0, 0.5), // R,G,B,Opacity(AppBar 배경)
    // color: Colors.amber, // 색상명 (AppBar 배경)
    elevation: 1,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
    actionsIconTheme: IconThemeData(color: Colors.white),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xff8338EC), // bottomBar 배경 색상
    selectedItemColor: Colors.white, // 선택된 아이콘 색상
    unselectedItemColor: Colors.white.withOpacity(.40), // 선택안된 아이콘 색상
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xff8338EC), // floating 버튼 색상
    foregroundColor: Colors.white, // floating 버튼 + 텍스트 색상
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: Color(0xff8338EC), // 배경 색상(ElevatedButton) - background
      onPrimary: Colors.white, // 텍스트 색상(ElevatedButton) - foreground
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      primary: Colors.black, // TextButton 색상
      // backgroundColor: Color(0xff8338EC), // TextButton 에는 굳이 배경을 쓸필요가 없을듯?
      // shape: RoundedRectangleBorder( // 배경을 주게 되면 radius 값 설정해서 모서리 세팅
      //   borderRadius: BorderRadius.circular(20),
      // ),
    ),
  ),
  textTheme: TextTheme(
    bodyText1: TextStyle(color: Colors.black, fontSize: 20),
    bodyText2: TextStyle(color: Colors.black, fontSize: 15), // body내의 일반 텍스트
  ),
);
