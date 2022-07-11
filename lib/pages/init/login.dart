import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 페이지'),
      ),
      // body for route contacts page
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('로그인 페이지입니다.'),
            ElevatedButton(
              child: const Text('로그인 테스트 => 연락처 페이지'),
              onPressed: () {
                Navigator.pushNamed(context, '/contacts');
              },
            ),
          ],
        ),
      ),
    );
  }
}
