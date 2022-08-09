import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../secrets.dart';
import 'package:url_launcher/url_launcher.dart';

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
  var loginID;
  bool isChecked = false;
  bool isuserChecked = false;

  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  saveIdSecure(id) async {
    var val = jsonEncode(Login('$accountName', '$password', '$id'));
    await storage.write(key: 'login', value: val);
  }
  //
  // saveData(id) async {
  //   // 임시이며, SecureStorage로 이관예정
  //   var storage = await SharedPreferences.getInstance();
  //   storage.setInt('id', id);
  //   // var result = storage.getInt('id');
  //   // print('saveData result: $result');
  // }

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
      decoration: signupDecoration('아이디'),
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
      decoration: signupDecoration('비밀번호'),
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
      decoration: signupDecoration('비밀번호 재확인'),
      onChanged: (text) {
        setState(() {
          passwordAgain = text;
        });
      },
    );
  }

  changePhoneNumber() {
    return TextField(
      decoration: signupDecoration('휴대전화'),
      onChanged: (text) {
        setState(() {
          phoneNumber = text;
        });
      },
    );
  }

  checkNemoAgreements() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RichText(
          // style: TextStyle(fontSize: 13),
          text: TextSpan(children: [
            TextSpan(
                text: '네모 서비스 이용약관',
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final uri = Uri.parse(
                        'https://sites.google.com/view/nemoserviceguide/%ED%99%88');
                    if (!await launchUrl(uri)) {
                      throw 'Could not launch $uri';
                    }
                  }),
            TextSpan(text: '에 동의합니다', style: TextStyle(color: Colors.black))
          ]),
        ),
        // controlAffinity: ListTileControlAffinity.platform,
        Checkbox(
          value: isuserChecked,
          onChanged: (bool? value) {
            setState(() {
              isuserChecked = value!;
            });
          },
          activeColor: Colors.blue,
          checkColor: Colors.white,
        ),
      ],
    );
  }

  checkAgreements() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RichText(
          // style: TextStyle(fontSize: 13),
          text: TextSpan(children: [
            TextSpan(
                text: '개인정보 처리방침',
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final uri = Uri.parse(
                        'https://sites.google.com/view/nemo-privacy-agreements/home');
                    if (!await launchUrl(uri)) {
                      throw 'Could not launch $uri';
                    }
                  }),
            TextSpan(text: '에 동의합니다', style: TextStyle(color: Colors.black))
          ]),
        ),
        // controlAffinity: ListTileControlAffinity.platform,
        Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
            });
          },
          activeColor: Colors.blue,
          checkColor: Colors.white,
        ),
      ],
    );
  }

  checktext() {
    return Center(child: Text('미동의시 서비스 이용이 제한될 수 있습니다'));
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
    // Response response;
    try {
      var dio = Dio();
      var param = {
        'account_name': '$account',
        'password': '$password',
        'phone_number': '$phonenumber'
      };
      Response response = await dio.post('${API_URL}user/signup', data: param);
      if (response.statusCode == 201) {
        final json = response.data;
        setState(() {
          loginID = json['id'];
        });
        saveIdSecure(json['id']);
        print('success : $json');
        return true;
      } else {
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
    final List<Function> functions = [
      showNemo,
      changeAccountName,
      changePassword,
      changePasswordAgain,
      changePhoneNumber,
      checkNemoAgreements,
      checkAgreements,
      checktext,
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
                  } else if (isChecked == false) {
                    errorDialog('서비스 이용약관 및 개인정보 처리방침에 동의해주세요.');
                  } else if (isuserChecked == false) {
                    errorDialog('서비스 이용약관 및 개인정보 처리방침에 동의해주세요.');
                  } else {
                    print('Trying to POST signup. . . ');
                    if (await postUser(accountName, password, phoneNumber) ==
                        true) {
                      Navigator.pushNamed(context, '/namecard');
                    } else {
                      errorDialog(errorDetail);
                    }
                  }
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
