import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('메인'),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            ElevatedButton(
              child: const Text('명함 생성'),
              onPressed: () {
                Navigator.pushNamed(context, '/namecard');
              },
            ),
          ],
        ),
      ),
    );
  }
}
