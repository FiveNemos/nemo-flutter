import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../sharing/sharing.dart';

Future<dynamic> postNameCard(dynamic context, int nowID, String nickname,
    Map tags, String introduction, dynamic userImage) async {
  print('nowID : $nowID');
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
        {'Content-Type': 'multipart/form-data; boundary=----myboundary'});
    request.files
        .add(await http.MultipartFile.fromPath('image', userImage.path));
    request.fields['user_id'] = nowID.toString();
    request.fields['nickname'] = nickname;
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

class NameCardGenerator extends StatefulWidget {
  const NameCardGenerator({Key? key}) : super(key: key);

  @override
  State<NameCardGenerator> createState() => _NameCardGeneratorState();
}

class _NameCardGeneratorState extends State<NameCardGenerator> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  var nickname = '닉네임';
  var tags = {'1': '#', '2': '#', '3': '#'};
  var introduction = '한줄소개';
  dynamic userImage;
  dynamic tagImage1, tagImage2, tagImage3;

  logout() async {
    await storage.delete(key: 'login');
    Navigator.pushNamed(context, '/login');
  }

  saveTagImage(int num, File picture) {
    setState(() {
      if (num == 1) {
        tagImage1 = picture;
      } else if (num == 2) {
        tagImage2 = picture;
      } else {
        tagImage3 = picture;
      }
    });
  }

  getTagImage() {
    setState(() {
      tagImage1 = Image.asset('assets/mypage/grey_gallery.png');
      tagImage2 = Image.asset('assets/mypage/grey_gallery.png');
      tagImage3 = Image.asset('assets/mypage/grey_gallery.png');
    });
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  saveName(String value) {
    setState(() {
      nickname = value;
    });
  }

  saveTags(int num, String value) {
    setState(() {
      tags['$num'] = value;
    });
  }

  saveIntro(String value) {
    setState(() {
      introduction = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTagImage();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('명함 생성'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(fixedSize: Size(40, 40)),
                child: Text('저장'),
                onPressed: () {
                  postNameCard(context, arguments['nowId'], nickname, tags,
                      introduction, userImage);
                },
              ),
              IconButton(
                icon: Icon(Icons.logout),
                tooltip: 'logout',
                onPressed: () {
                  logout();
                },
              ),
            ]),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NameCard(
                    nickname: nickname,
                    tags: tags,
                    introduction: introduction,
                    userImage: userImage,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  NameSpace(nickname: nickname, saveName: saveName),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  IntroSpace(introduction: introduction, saveIntro: saveIntro),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  Wrap(
                    spacing: 8, // main axis of the wrap
                    runSpacing: 20, // cross axis of the wrap
                    children: [
                      SizedBox(
                        width: 70,
                        height: 50,
                        child: TagSpace(saveTags: saveTags, num: 1),
                      ),
                      SizedBox(
                        width: 70,
                        height: 50,
                        child: TagSpace(saveTags: saveTags, num: 2),
                      ),
                      SizedBox(
                        width: 70,
                        height: 50,
                        child: TagSpace(saveTags: saveTags, num: 3),
                      )
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  Wrap(
                    spacing: 8, // main axis of the wrap
                    runSpacing: 20, // cross axis of the wrap
                    children: [
                      SizedBox(
                        width: 70,
                        height: 50,
                        child: imageSpace(
                          saveTagImage: saveTagImage,
                          num: 1,
                          tagImage1: tagImage1,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        height: 50,
                        child: imageSpace(
                          saveTagImage: saveTagImage,
                          num: 2,
                          tagImage2: tagImage2,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        height: 50,
                        child: imageSpace(
                          saveTagImage: saveTagImage,
                          num: 3,
                          tagImage3: tagImage3,
                        ),
                      )
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  TextField(
                    decoration: InputDecoration(
                      constraints: BoxConstraints(maxHeight: 40),
                      labelText: 'title',
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
                      // widget.saveName(text);
                    },
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  TextField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      constraints: BoxConstraints(maxHeight: 40),
                      labelText: 'details',
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
                      // widget.saveName(text);
                    },
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

class imageSpace extends StatefulWidget {
  imageSpace(
      {Key? key,
      this.saveTagImage,
      this.num,
      this.tagImage1,
      this.tagImage2,
      this.tagImage3})
      : super(key: key);
  var saveTagImage;
  var num;
  var tagImage1, tagImage2, tagImage3;

  @override
  State<imageSpace> createState() => _imageSpaceState();
}

class _imageSpaceState extends State<imageSpace> {
  @override
  Widget build(BuildContext context) {
    if (widget.num == 1) {
      return InkWell(
        child: (widget.tagImage1.runtimeType == Image)
            ? widget.tagImage1
            : Image.file(widget.tagImage1),
        onTap: () async {
          var picker = ImagePicker();
          var picture = await picker.pickImage(source: ImageSource.gallery);
          if (picture != null) {
            widget.saveTagImage(widget.num, File(picture.path));
          }
        },
      );
    } else if (widget.num == 2) {
      return InkWell(
        child: (widget.tagImage2.runtimeType == Image)
            ? widget.tagImage2
            : Image.file(widget.tagImage2),
        onTap: () async {
          var picker = ImagePicker();
          var picture = await picker.pickImage(source: ImageSource.gallery);
          if (picture != null) {
            widget.saveTagImage(widget.num, File(picture.path));
          }
        },
      );
    } else {
      return InkWell(
        child: (widget.tagImage3.runtimeType == Image)
            ? widget.tagImage3
            : Image.file(widget.tagImage3),
        onTap: () async {
          var picker = ImagePicker();
          var picture = await picker.pickImage(source: ImageSource.gallery);
          if (picture != null) {
            widget.saveTagImage(widget.num, File(picture.path));
          }
        },
      );
    }
  }
}

class NameSpace extends StatefulWidget {
  NameSpace({
    Key? key,
    this.nickname,
    this.saveName,
  }) : super(key: key);
  var nickname, saveName;

  @override
  State<NameSpace> createState() => _NameSpaceState();
}

class _NameSpaceState extends State<NameSpace> {
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
        widget.saveName(text);
      },
    );
  }
}

class TagSpace extends StatefulWidget {
  TagSpace({Key? key, this.saveTags, this.num}) : super(key: key);
  var saveTags;
  var num;

  @override
  State<TagSpace> createState() => _TagSpaceState();
}

class _TagSpaceState extends State<TagSpace> {
  var controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: (text) {
        widget.saveTags(widget.num, text);
      },
      decoration: InputDecoration(
        constraints: BoxConstraints(maxHeight: 40),
        hintText: '',
        labelText: '태그',
        labelStyle: TextStyle(
            // color: Colors.red,
            ),
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
    );
  }
}

class IntroSpace extends StatefulWidget {
  IntroSpace({Key? key, this.introduction, this.saveIntro}) : super(key: key);
  var introduction, saveIntro;

  @override
  State<IntroSpace> createState() => _IntroSpaceState();
}

class _IntroSpaceState extends State<IntroSpace> {
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
          widget.saveIntro(text);
        });
  }
}

class NameCard extends StatefulWidget {
  NameCard({
    Key? key,
    this.nickname,
    this.tags,
    this.introduction,
    this.userImage,
  }) : super(key: key);

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
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
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
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 100,
                height: 85,
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                decoration: BoxDecoration(color: Colors.red),
                child: GestureDetector(
                  onTap: () async {
                    var picker = ImagePicker();
                    var image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        widget.userImage = File(image.path);
                      });
                    }
                  },
                  child: widget.userImage == null
                      ? Image.asset("assets/grey_profile.png", fit: BoxFit.fill)
                      : Image.file(widget.userImage, fit: BoxFit.fill),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.fromLTRB(0, 2, 0, 0)),
              Text(
                widget.nickname,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(widget.introduction,
                  style: TextStyle(
                    fontSize: 13,
                  )),
              Wrap(
                direction: Axis.horizontal, // 정렬 방향
                alignment: WrapAlignment.start, // 정렬 방식
                spacing: 10, // main axis of the wrap
                runSpacing: 20, // cross axis of the wrap
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(),
                      child: Text(widget.tags['1'])),
                  OutlinedButton(
                    child: Text(widget.tags['2']),
                    onPressed: () {},
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(),
                    child: Text(widget.tags['3']),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
