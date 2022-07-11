import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('네모 샘플'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('로그인'),
            ElevatedButton(
              child: const Text('로그인 성공 -> 연락처로'),
              onPressed: () {
                Navigator.pushNamed(context, '/contacts');
              },
            ),
            ElevatedButton(
              child: const Text('회원가입'),
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
            ),
          ],
        ),
      ),
    );
  }
}
