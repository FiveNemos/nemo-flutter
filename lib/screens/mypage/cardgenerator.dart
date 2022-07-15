import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;

import '../sharing/sharing.dart';

Future<dynamic> postNameCard(dynamic context, String nickname, Map tags,
    String introduction, dynamic userImage) async {
  if (userImage.runtimeType == String) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Not Yet!!'),
              content: Text('사진을 바꿔주세요.'),
              actions: [
                TextButton(
                  // textColor: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('확인'),
                )
              ]);
        });
  } else {
    var uri = Uri.parse('http://34.64.217.3:3000/api/card/create');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(
        {"Content-Type": "multipart/form-data; boundary=----myboundary"});
    request.files
        .add(await http.MultipartFile.fromPath("image", userImage.path));
    request.fields['user_id'] = "9999";
    request.fields['nickname'] = "Hyunjoo";
    request.fields['tag_1'] = tags['1'];
    request.fields['tag_2'] = tags['2'];
    request.fields['tag_3'] = tags['3'];
    request.fields['intro'] = introduction;

    final response = await request.send();

    if (response.statusCode == 201) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('저장완료'),
                content: Text('저장이 완료되었습니다.'),
                actions: [
                  TextButton(
                    // textColor: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SharingPage(),
                        ),
                      );
                    },
                    child: Text('확인'),
                  )
                ]);
          });
    } else {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('저장실패'),
                content: Text('재시도하세요'),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.star))
                ]);
          });
      // throw Exception('명함 저장 실패');
    }
  }
}

// (
//   Uri.parse('http://34.64.217.3:3000/api/card/create'),
//     headers: <String, String>{
//     "Content-Type": "multipart/form-data"
//     },
//   body: {
//     "user_id": "9999",
//     "nickname": nickname,
//     "tag_1": tags['0'],
//     "tag_2": tags['1'],
//     "tag_3": tags['2'],
//     "intro": introduction,
//     "image": userImage,
//   },
// );

class NameCardGenerator extends StatefulWidget {
  const NameCardGenerator({Key? key}) : super(key: key);

  @override
  State<NameCardGenerator> createState() => _NameCardGeneratorState();
}

class _NameCardGeneratorState extends State<NameCardGenerator> {
  var nickname = '닉네임';
  // var tag1 = '태그1', tag2 = '태그2', tag3 = '태그3';
  var tags = {'1': 'one', '2': 'two', '3': 'three'};
  var introduction = '한줄소개';
  // var userImage = Image.asset('assets/grey_profile.png', fit: BoxFit.fill); //이건 파일형태가 아니군!
  dynamic userImage =
      'https://www.docker.com/wp-content/uploads/2022/03/vertical-logo-monochromatic.png';

  saveName(String value) {
    setState(() {
      nickname = value;
    });
  }

  saveTags(int num, String value) {
    setState(() {
      tags['${num}'] = value;
    });
    // if (num == 1){
    //   setState(() {
    //     tag1 = value;
    //   });
    // } else if (num == 2){
    //   setState(() {
    //     tag2 = value;
    //   });
    // } else {
    //   setState(() {
    //     tag3 = value;
    //   });
    // }
  }

  saveIntro(String value) {
    setState(() {
      introduction = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // FocusScopeNode currentFocus = FocusScope.of(context);
        // if (!currentFocus.hasPrimaryFocus){
        //   currentFocus.unfocus();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: Text('명함 생성'), actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(fixedSize: Size(40, 40)),
            child: Text('저장'),
            onPressed: () {
              postNameCard(context, nickname, tags, introduction, userImage);
              // showDialog(
              //     context: context,
              //     builder: (context){
              //       return AlertDialog(
              //           title: Text('저장완료'),
              //           content: Text('가입이 완료되었습니다.'),
              //           actions: [
              //             TextButton(
              //               // textColor: Colors.black,
              //               onPressed: (){
              //                 Navigator.pushNamed(context, '/');
              //               },
              //               child: Text('확인'),
              //             )
              //           ]
              //         );});
            },
          )
        ]),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: Column(
                children: [
                  NameCard(
                      nickname: nickname,
                      tags: tags,
                      introduction: introduction,
                      userImage: userImage),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  ),
                  ElevatedButton(
                    child: Text('사진 가져오기'),
                    // icon: Icon(Icons.add_box_rounded),
                    onPressed: () async {
                      var picker = ImagePicker();
                      var image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          // userImage = Image.file(File(image.path), fit: BoxFit.fill);
                          userImage = File(image.path);
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  ),
                  nameSpace(nickname: nickname, saveName: saveName),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 50,
                        child: tagSpace(saveTags: saveTags, num: 1),
                      ),
                      SizedBox(
                        width: 70,
                        height: 50,
                        child: tagSpace(saveTags: saveTags, num: 2),
                      ),
                      SizedBox(
                        width: 70,
                        height: 50,
                        child: tagSpace(saveTags: saveTags, num: 3),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  ),
                  introSpace(
                    introduction: introduction,
                    saveIntro: saveIntro,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class nameSpace extends StatefulWidget {
  nameSpace({
    Key? key,
    this.nickname,
    this.saveName,
  }) : super(key: key);
  var nickname, saveName;

  @override
  State<nameSpace> createState() => _nameSpaceState();
}

class _nameSpaceState extends State<nameSpace> {
  var controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        constraints: BoxConstraints(maxHeight: 40),
        labelText: '닉네임',
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
      // controller: controller,
      onChanged: (text) {
        if (text != null) {
          // setState(() {
          //   widget.nickname = text;
          // });
          // print(widget.nickname);
          widget.saveName(text);
        }
      },
    );
  }
}

class tagSpace extends StatefulWidget {
  tagSpace({Key? key, this.saveTags, this.num}) : super(key: key);
  var saveTags;
  var num;

  @override
  State<tagSpace> createState() => _tagSpaceState();
}

class _tagSpaceState extends State<tagSpace> {
  var controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        constraints: BoxConstraints(maxHeight: 50, maxWidth: 70),
        hintText: '',
        labelText: '태그 *',
      ),
      controller: controller,
      onChanged: (text) {
        if (text != null) {
          widget.saveTags(widget.num, text);
        }
      },
    );
  }
}

class introSpace extends StatefulWidget {
  introSpace({Key? key, this.introduction, this.saveIntro}) : super(key: key);
  var introduction, saveIntro;

  @override
  State<introSpace> createState() => _introSpaceState();
}

class _introSpaceState extends State<introSpace> {
  var controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
          constraints: BoxConstraints(maxHeight: 40),
          labelText: '한줄소개',
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
        onChanged: (text) {
          if (text != null) {
            // setState(() {
            //   widget.introduction = controller.text;
            // });
            widget.saveIntro(text);
          }
        });
  }
}

class NameCard extends StatefulWidget {
  NameCard(
      {Key? key, this.nickname, this.tags, this.introduction, this.userImage})
      : super(key: key);
  var nickname, tags, introduction;
  dynamic userImage;

  @override
  State<NameCard> createState() => _NameState();
}

class _NameState extends State<NameCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          ),
          Container(
            width: 100,
            height: 85,
            // decoration: BoxDecoration(color: Colors.red),
            child: widget.userImage.runtimeType == String
                ? Image.network(widget.userImage, fit: BoxFit.fill)
                : Image.file(widget.userImage, fit: BoxFit.fill),
          ),
          Text(
            widget.nickname,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                  child: Text(widget.tags['1']),
                  onPressed: () {},
                  style: ButtonStyle()),
              OutlinedButton(
                child: Text(widget.tags['2']),
                onPressed: () {},
              ),
              ElevatedButton(
                child: Text(widget.tags['3']),
                onPressed: () {},
                style: ButtonStyle(),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
          ),
          Text(widget.introduction, style: TextStyle(fontSize: 14)),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
          ),
        ], //children
      ),
    );
  }
}
