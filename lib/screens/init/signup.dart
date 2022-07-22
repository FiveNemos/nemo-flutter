import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/init/login.dart';

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
  var errorDetail;
  var uniqueID;
  var loginID;

  // static final storage = FlutterSecureStorage();
  // dynamic userInfo = '';
  // saveIdSecure() async{
  //   var val = jsonEncode(Login('$accountName', '$password', '$jsonBody'));
  //   userInfo = await storage.write(
  //     key: 'login',
  //     value: j
  //   )
  // }
  saveData(id) async {
    // 임시이며, SecureStorage로 이관예정
    var storage = await SharedPreferences.getInstance();
    storage.setInt('id', id);
    // var result = storage.getInt('id');
    // print('saveData result: $result');
  }

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

  postUser(account, password, phonenumber) async {
    // print('http://34.64.217.3:3000/api/card/$id');
    // Response response;
    try {
      var dio = Dio();
      var param = {
        'account_name': '$account',
        'password': '$password',
        'phone_number': '$phonenumber'
      };
      print('gopostUser');
      Response response = await dio
          .post('http://34.64.217.3:3000/api/user/signup', data: param);
      print('response status: ${response.statusCode}');
      if (response.statusCode == 201) {
        print("go success");
        final json = response.data;
        print(json['id']);
        setState(() {
          uniqueID = json['id'];
        });
        saveData(json['id']);
        print('접속 성공!');
        print('success : $json');
        return true;
      } else {
        print('go fail, statusCode: ${response.statusCode}');
        print('error');
        return false;
      }
    } on DioError catch (e) {
      final errorjson = jsonDecode(e.response.toString());
      setState(() {
        errorDetail = errorjson['msg'];
      });
      print('catched error');
      return false;
    }
  }

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
            ElevatedButton(
                style: ElevatedButton.styleFrom(fixedSize: Size(40, 40)),
                child: Text('확인'),
                onPressed: () async {
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
                    print('Trying to POST signup. . . ');
                    if (await postUser(accountName, password, phoneNumber) ==
                        true) {
                      Navigator.pushNamed(context, '/namecard',
                          arguments: {'nowId': uniqueID});
                    } else {
                      errorDialog(errorDetail);
                    }
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
