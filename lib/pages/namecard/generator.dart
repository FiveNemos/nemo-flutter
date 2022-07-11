import 'package:flutter/material.dart';

class NameCardGenerator extends StatelessWidget {
  const NameCardGenerator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('명함 생성'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('메인 페이지로 이동'),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
    );
  }
}
