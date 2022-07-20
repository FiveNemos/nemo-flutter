import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  var accountName;
  var password;
  var passwordAgain;
  var phoneNumber;
  var accountName2 = TextEditingController();

  showNemo() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(20.0), // NEMO 글자와 아이디 입력칸 사이의 간격
      child: Text(
        'NEMO',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
      ),
    ));
  }

  changeAccountName() {
    return TextField(
      decoration: signupDecoration("아이디"),
      onChanged: (text) {
        setState(() {
          accountName = text;
        });
      },
    );
  }

  changePassword() {
    return TextField(
      obscureText: true,
      decoration: signupDecoration("비밀번호"),
      onChanged: (text) {
        setState(() {
          password = text;
        });
      },
    );
  }

  changePasswordAgain() {
    return TextField(
      obscureText: true,
      decoration: signupDecoration("비밀번호 재확인"),
      onChanged: (text) {
        setState(() {
          passwordAgain = text;
        });
      },
    );
  }

  changePhoneNumber() {
    return TextField(
      decoration: signupDecoration("휴대전화"),
      onChanged: (text) {
        setState(() {
          phoneNumber = text;
        });
      },
    );
  }

  signupDecoration(labelText) {
    return InputDecoration(
      constraints: BoxConstraints(maxHeight: 45),
      labelText: labelText,
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
    );
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

  // getMyCard(id) async {
  //   // print('http://34.64.217.3:3000/api/card/$id');
  //   try {
  //     var dio = Dio();
  //     Response response = await dio.get('http://34.64.217.3:3000/api/card/$id');
  //     if (response.statusCode == 200) {
  //       final json = response.data;
  //       setState(() {});
  //       print('접속 성공!');
  //       print('json : $json');
  //       return true;
  //     } else {
  //       print('error');
  //       return false;
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var testList = ['아이디', '비밀번호', '비밀번호 재확인'];
    final List<Function> functions = [
      showNemo,
      changeAccountName,
      changePassword,
      changePasswordAgain,
      changePhoneNumber,
    ];
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('회원가입 페이지'),
          actions: [
            FloatingActionButton(
                child: Text('확인'),
                onPressed: () {
                  RegExp accountNameExp = RegExp(r'[a-z0-9]{5,20}$');
                  RegExp passwordExp = RegExp(r'[A-Za-z0-9!@^]{5,16}$');
                  RegExp phoneNumberExp = RegExp(r'010\d{8}');
                  if (!accountNameExp.hasMatch(accountName)) {
                    errorDialog('아이디는 5~20자의 영문 소문자, 숫자만 사용 가능합니다.');
                  } else if (password != passwordAgain) {
                    errorDialog('비밀번호가 일치하지 않습니다');
                  } else if (!passwordExp.hasMatch(password)) {
                    errorDialog('비밀번호는 5~16자의 영문 대소문자, 숫자, @!^ 만 사용 가능합니다.');
                  } else if (!phoneNumberExp.hasMatch(phoneNumber)) {
                    errorDialog('유효하지 않은 전화번호입니다.\n -을 제외한 11자리 번호만 입력해주세요!');
                  } else {
                    errorDialog(
                        '정상적으로 완료!'); // 여기에 POST 작업 + cardgenerator로 이어지도록.
                  }
                  // ElevatedButton(
                  //           child: const Text('메인'),
                  //           onPressed: () {
                  //             Navigator.pushNamed(context, '/');
                  //           },
                  //         ),
                  //         ElevatedButton(
                  //           child: const Text('명함 생성'),
                  //           onPressed: () {
                  //             Navigator.pushNamed(context, '/namecard');
                  //           },
                  //         ),
                  // print('확인: $accountName $password $passwordAgain');
                }),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(30),
          margin: EdgeInsets.all(30),
          // color: Colors.red,
          child: ListView.separated(
            itemCount: functions.length,
            itemBuilder: (c, i) {
              return functions[i]();
            },
            separatorBuilder: (context, i) => SizedBox(height: 25),
          ),
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
