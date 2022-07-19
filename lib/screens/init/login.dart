import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert'; // json decode 등등 관련 패키지
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/init/login.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var inputData = TextEditingController();
  var inputData2 = TextEditingController();

  static final storage = FlutterSecureStorage();

  dynamic userInfo = '';
  //flutter_secure_storage 사용을 위한 초기화 작업
  @override
  void initState() {
    super.initState();

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    //read 함수를 통하여 key값에 맞는 정보를 불러오게 됩니다. 이때 불러오는 결과의 타입은 String 타입임을 기억해야 합니다.
    //(데이터가 없을때는 null을 반환을 합니다.)
    userInfo = await storage.read(key: 'login');

    //user의 정보가 있다면 바로 contacts 페이지로 넘어가게 합니다.
    if (userInfo != null) {
      Navigator.pushNamed(context, '/contacts');
    } else {
      print('로그인이 필요합니다');
    }
  }

  getHttp(accountName, password) async {
    try {
      var dio = Dio();
      var param = {'account_name': '$accountName', 'password': '$password'};
      print(param);

      Response response =
          await dio.post('http://34.64.217.3:3000/api/user/login', data: param);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.data['user_id'].toString());
        var val = jsonEncode(Login('$accountName', '$password', '$jsonBody'));
        await storage.write(
          key: 'login',
          value: val,
        );
        print('접속 성공!');
        return true;
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: ListView(
          children: [
            Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Image.asset('assets/common/logo.png'),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    ),
                    TextField(
                      controller: inputData,
                      maxLength: 10, // 입력 값 제한
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Color(0xff8338EC)),
                        counterText: '', // 입력 문자 개수 제한 걸었을 경우 '' 하면 텍스트 노출 안됨
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xff8338EC),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xff8338EC),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    ),
                    TextField(
                      controller: inputData2,
                      obscureText: true, // 입력문자 가리기
                      maxLength: 10, // 입력 문자 개수 제한
                      onSubmitted: (text) async {
                        if (await getHttp(inputData.text, inputData2.text) ==
                            true) {
                          print('로그인 성공');
                          Navigator.pushNamed(context, '/contacts');
                        } else {
                          print('로그인 실패');
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Color(0xff8338EC)),
                        counterText: '', // 입력 문자 개수 제한 걸었을 경우 '' 하면 텍스트 노출 안됨
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xff8338EC),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xff8338EC),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (await getHttp(inputData.text, inputData2.text) ==
                              true) {
                            print('로그인 성공');
                            Navigator.pushNamed(context, '/contacts');
                          } else {
                            print('로그인 실패');
                          }
                        },
                        child: Text('Continue'),
                        style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                                TextStyle(fontSize: 17)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    ),
                    TextButton(
                        child: Text(
                          'Create an account',
                          style:
                              TextStyle(color: Color(0xff8338EC), fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 25),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            print('네이버 로그인');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 5,
                                    color: Colors.black26,
                                    spreadRadius: 1)
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage('assets/login/logo_naver.png'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 60, 0),
                        ),
                        InkWell(
                          onTap: () {
                            print('구글 로그인');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 5,
                                    color: Colors.black26,
                                    spreadRadius: 1)
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage('assets/login/logo_google.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 25),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
