import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  SizedBox(
                    width: 300,
                    child : Image.asset('assets/common/logo.png'),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10),),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:(){},
                      child: Text('Continue'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                        textStyle: MaterialStateProperty.all(TextStyle(fontSize: 17)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                            )
                        )
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10),),
                  TextButton(
                    child: Text(
                      'Create an account',
                      style: TextStyle( color: Colors.black, fontSize: 16),
                    ),
                    onPressed:(){
                      Navigator.pushNamed(context, '/signup');
                    }
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 25),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          print('네이버 로그인');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26, spreadRadius: 1)],
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/login/logo_naver.png'),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 60, 0),),
                      InkWell(
                        onTap: (){
                          print('구글 로그인');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26, spreadRadius: 1)],
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/login/logo_google.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 25),),
                  ElevatedButton(
                    child: const Text('로그인 성공 -> 연락처로'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/contacts');
                    },
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}
