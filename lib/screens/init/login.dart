import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert'; // json decode 등등 관련 패키지
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/init/login.dart';
// shared preference
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var inputData = TextEditingController();
  var inputData2 = TextEditingController();
  var loginID;
  var errorDetail;

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
    //혹시나 user의 정보가 남아있다면 삭제하도록 합니다.
    if (userInfo != null) {
      await storage.delete(key: 'login');
    }
    var sharedstorage = await SharedPreferences.getInstance();
    sharedstorage.clear();
  }
// shared preference 주석처리 (keep)
  // saveData(id) async {
  //   var storage = await SharedPreferences.getInstance();
  //   storage.setInt('id', id);
  //   // var result = storage.getInt('id');
  //   // print('saveData result: $result');
  //   setState(() {
  //     loginID = id;
  //   });
  // }

  getHttp(accountName, password) async {
    try {
      var dio = Dio();
      var param = {'account_name': '$accountName', 'password': '$password'};
      print(param);

      Response response =
          await dio.post('http://34.64.217.3:3000/api/user/login', data: param);

      if (response.statusCode == 200) {
        loginID = response.data['user_id'];
        // saveData(response.data['user_id']);
        final jsonBody = json.decode(response.data['user_id'].toString());
        var val = jsonEncode(Login('$accountName', '$password', '$jsonBody'));
        await storage.write(
          key: 'login',
          value: val,
        );
        print('접속 성공!');
        return true;
      } else {
        print('error404');
        return false;
      }
    } on DioError catch (e) {
      setState(() {
        errorDetail = e.response.toString();
      });
      return false;
    }
  }

  findCard(id) async {
    try {
      var dio = Dio();

      Response response = await dio.get('http://34.64.217.3:3000/api/card/$id');
      print(response.data);
      print(response.data.runtimeType);

      if (response.data.runtimeType != bool) {
        print('카드 존재 확인!');
        return true;
      } else {
        print('카드 미생성 확인');
        return false;
      }
    } catch (e) {
      print('카드 미생성 확인 @ 에러');
      return false;
    }
  }

  errorDialog(msg) {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: DialogUI(
              errorMsg: msg,
            ),
          );
        });
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
                      // onSubmitted: (text) async {
                      //   if (await getHttp(inputData.text, inputData2.text) ==
                      //       true) {
                      //     print('로그인 성공');
                      //     Navigator.pushNamed(context, '/contacts');
                      //   } else {
                      //     print('로그인 실패');
                      //   }
                      // },
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
                            print('loginID : $loginID');
                            if (await findCard(loginID) == true) {
                              print('card 찾음');
                              Navigator.pushNamed(context, '/sharing');
                            } else {
                              print('card 못찾음');
                              Navigator.pushNamed(
                                context, '/namecard',
                                // arguments: {'nowId': loginID}
                              );
                            }
                          } else {
                            errorDialog(errorDetail);
                          }
                        },
                        style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                                TextStyle(fontSize: 17)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ))),
                        child: Text('Continue'),
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     InkWell(
                    //       onTap: () {
                    //         print('네이버 로그인');
                    //       },
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //           color: Colors.white,
                    //           shape: BoxShape.circle,
                    //           boxShadow: [
                    //             BoxShadow(
                    //                 blurRadius: 5,
                    //                 color: Colors.black26,
                    //                 spreadRadius: 1)
                    //           ],
                    //         ),
                    //         child: CircleAvatar(
                    //           radius: 20,
                    //           backgroundImage:
                    //               AssetImage('assets/login/logo_naver.png'),
                    //         ),
                    //       ),
                    //     ),
                    //     Padding(
                    //       padding: EdgeInsets.fromLTRB(0, 0, 60, 0),
                    //     ),
                    //     InkWell(
                    //       onTap: () {
                    //         print('구글 로그인');
                    //         // Navigator.pushNamed(context, '/map');
                    //       },
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //           color: Colors.white,
                    //           shape: BoxShape.circle,
                    //           boxShadow: [
                    //             BoxShadow(
                    //                 blurRadius: 5,
                    //                 color: Colors.black26,
                    //                 spreadRadius: 1)
                    //           ],
                    //         ),
                    //         child: CircleAvatar(
                    //           radius: 20,
                    //           backgroundImage:
                    //               AssetImage('assets/login/logo_google.png'),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
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

class DialogUI extends StatelessWidget {
  DialogUI({Key? key, this.errorMsg}) : super(key: key);
  var errorMsg;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        alignment: Alignment.center,
        child: SizedBox(
          height: 100,
          width: double.infinity,
          child: Center(
            child: Text(
              errorMsg,
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }
}
