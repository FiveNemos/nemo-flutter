import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../sharing/sharing.dart';

Future<dynamic> postNameCard(
  dynamic context,
  nowID,
  String nickname,
  Map tags,
  introduction,
  dynamic userImage,
  dynamic tagImage1,
  dynamic tagImage2,
  dynamic tagImage3,
  String detailTitle,
  String detailContent,
) async {
  print('nowID : $nowID');
  if (userImage == null ||
      tagImage1.runtimeType == Image ||
      tagImage2.runtimeType == Image ||
      tagImage3.runtimeType == Image) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('아직 완성되지 않았습니다!'),
              content: Text('모든 사진을 채워주세요 🙏'),
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
    print('http post 요청 들어옴');
    var uri = Uri.parse('http://34.64.217.3:3000/api/card/create');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(
        {'Content-Type': 'multipart/form-data; boundary=----myboundary'});
    request.files
        .add(await http.MultipartFile.fromPath('image', userImage.path));
    request.files
        .add(await http.MultipartFile.fromPath('tag_img_1', tagImage1.path));
    request.files
        .add(await http.MultipartFile.fromPath('tag_img_2', tagImage2.path));
    request.files
        .add(await http.MultipartFile.fromPath('tag_img_3', tagImage3.path));
    request.fields['user_id'] = nowID.toString();
    request.fields['nickname'] = nickname;
    request.fields['tag_1'] = tags['1'];
    request.fields['tag_2'] = tags['2'];
    request.fields['tag_3'] = tags['3'];
    request.fields['intro'] = introduction;
    request.fields['detail_title'] = detailTitle;
    request.fields['detail_content'] = detailContent;

    print('send');

    final response = await request.send();
    print('response');

    if (response.statusCode == 201) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('저장완료'),
                content: Text('명함이 저장되었습니다 😁'),
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
                content: Text('다시 시도해주세요..!'),
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
  /* login */
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  var nowId;
  /* cardgenerator */
  var nickname = '닉네임';
  var tags = {'1': '#태그', '2': '#태그', '3': '#태그'};
  var introduction = '한줄소개';
  dynamic userImage;
  dynamic tagImage1 = Image.asset('assets/mypage/grey_gallery.png');
  dynamic tagImage2 = Image.asset('assets/mypage/grey_gallery.png');
  dynamic tagImage3 = Image.asset('assets/mypage/grey_gallery.png');
  var detailTitle = '인삿말을 입력해주세요!';
  var detailContent = '더 하고픈 말이 있나요?';
  int editCount = 0;

  Future getImage(context) async {
    Uint8List bytes = Uint8List(0);

    var pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      await imageFile
          .readAsBytes()
          .then((value) => bytes = Uint8List.fromList(value))
          .catchError((onError) {
        print('Exception error while reading file from path');
      });
      print('pickedImage.path = ${pickedImage.path}!!!!!!!!!!!!!');
      // var finalImage = Image.file(imageFile);
      // var data = await rootBundle.load(pickedImage.path);
      var imageData = bytes.buffer.asUint8List();
      var editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditor(
            image: imageData,
          ),
        ),
      );
      // print('editedImage = ${editedImage.path}');
      if (editedImage != null) {
        Uint8List imageInUnit8List =
            editedImage; // store unit8List image here ;
        final tempDir = await getTemporaryDirectory();
        File file = await File('${tempDir.path}/image$editCount.png').create();
        file.writeAsBytesSync(imageInUnit8List);
        setState(() {
          userImage = file;
          editCount++;
        });
      } else {
        print('Edited Image was null~~~~~~~');
      }
      print('처리 다 끝났달룽~~~~~~~~~~');
    }
  }

  // saveUserImage(File file) {
  //   setState(() {
  //     userImage = file;
  //   });
  // }

  saveTagImage(int num, File picture) {
    setState(() {
      if (num == 1) {
        tagImage1 = picture;
      } else if (num == 2) {
        tagImage2 = picture;
        print(tagImage2.runtimeType);
      } else {
        tagImage3 = picture;
      }
    });
  }

  // Future<File> getImageFileFromAssets(String path) async {
  //   final byteData = await rootBundle.load('assets/$path');
  //   final file = File('${(await getTemporaryDirectory()).path}/$path');
  //   await file.writeAsBytes(byteData.buffer
  //       .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  //   return file;
  // }

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

  saveDetailTitle(String value) {
    setState(() {
      detailTitle = value;
    });
  }

  saveDetailContent(String value) {
    setState(() {
      detailContent = value;
    });
  }

  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      nowId = int.parse(jsonDecode(userInfo)['user_id']);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
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
                  postNameCard(
                      context,
                      nowId,
                      nickname,
                      tags,
                      introduction,
                      userImage,
                      tagImage1,
                      tagImage2,
                      tagImage3,
                      detailTitle,
                      detailContent);
                },
              ),
              IconButton(
                icon: Icon(Icons.logout),
                tooltip: 'logout',
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
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
                    getImage: getImage,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 25)),
                  SizedBox(
                    width: 200,
                    height: 34,
                    child: NameSpace(nickname: nickname, saveName: saveName),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  SizedBox(
                    height: 34,
                    child: IntroSpace(
                        introduction: introduction, saveIntro: saveIntro),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 80,
                              child: imageSpace(
                                saveTagImage: saveTagImage,
                                num: 1,
                                tagImage1: tagImage1,
                              ),
                            ),
                            Text(
                              '사진1',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                      SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 80,
                              child: imageSpace(
                                saveTagImage: saveTagImage,
                                num: 2,
                                tagImage2: tagImage2,
                              ),
                            ),
                            Text(
                              '사진2',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                      SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 80,
                              child: imageSpace(
                                saveTagImage: saveTagImage,
                                num: 3,
                                tagImage3: tagImage3,
                              ),
                            ),
                            Text(
                              '사진3',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(
                  //   width: 100,
                  //   height: 100,
                  //   child: ListView.separated(
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount: 3,
                  //     itemBuilder: (c, i) {
                  //       return Column(
                  //         children: [
                  //           Text('2'),
                  //           Text('${i + 1}'),
                  //         ],
                  //       );
                  //     },
                  //     separatorBuilder: (c, i) => SizedBox(width: 10),
                  //   ),
                  // ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (c, i) {
                        return SizedBox(
                          width: 100,
                          child: TagSpace(saveTags: saveTags, num: i + 1),
                        );
                      },
                      separatorBuilder: (c, i) => SizedBox(width: 10),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  SizedBox(
                    height: 35,
                    child: TextField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                      ],
                      decoration: InputDecoration(
                        labelText: detailTitle,
                        labelStyle: TextStyle(fontSize: 13),
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
                        saveDetailTitle(text);
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  TextField(
                    // keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 2,
                    maxLength: 50,
                    decoration: InputDecoration(
                      constraints: BoxConstraints(maxHeight: 80),
                      labelText: detailContent,
                      labelStyle: TextStyle(fontSize: 12),
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
                      saveDetailContent(text);
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
            : Image.file(widget.tagImage1, fit: BoxFit.cover),
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
            : Image.file(widget.tagImage2, fit: BoxFit.cover),
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
            : Image.file(widget.tagImage3, fit: BoxFit.cover),
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
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        constraints: BoxConstraints(maxHeight: 40),
        labelText: '닉네임',
        labelStyle: TextStyle(fontSize: 12),
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
      inputFormatters: [
        LengthLimitingTextInputFormatter(8),
      ],
      decoration: InputDecoration(
        hintText: '',
        labelText: '태그',
        labelStyle: TextStyle(fontSize: 12),
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
        inputFormatters: [
          LengthLimitingTextInputFormatter(30),
        ],
        decoration: InputDecoration(
          constraints: BoxConstraints(maxHeight: 40),
          labelText: '한줄소개',
          labelStyle: TextStyle(fontSize: 12),
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
    this.getImage,
    // this.saveUserImage,
  }) : super(key: key);

  var nickname, tags, introduction;
  dynamic userImage;
  // var saveUserImage;
  var getImage;

  @override
  State<NameCard> createState() => _NameState();
}

class _NameState extends State<NameCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(11)),
        border: Border.all(color: Colors.black),
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
                width: 140,
                height: 140,
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: GestureDetector(
                  onTap: () async {
                    await widget.getImage(context);
                  },
                  // var picker = ImagePicker();
                  // var image =
                  //     await picker.pickImage(source: ImageSource.gallery);
                  // if (image != null) {
                  //   widget.saveUserImage(File(image.path));
                  // }
                  // },
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                    child: widget.userImage == null
                        ? Image.asset('assets/grey_profile1.jpg',
                            fit: BoxFit.fill)
                        : Image.file(widget.userImage, fit: BoxFit.fill),
                  ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 2, 0, 0)),
              Text(
                widget.introduction,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
              Wrap(
                direction: Axis.vertical, // 정렬 방향
                alignment: WrapAlignment.start, // 정렬 방식
                spacing: 5, // main axis of the wrap
                runSpacing: 20, // cross axis of the wrap
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                    decoration: BoxDecoration(
                      color: Color(0xff8338EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.tags['1'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1.5,
                        color: Color(0xff8338EC),
                      ),
                    ),
                    child: Text(
                      widget.tags['2'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                    decoration: BoxDecoration(
                      color: Color(0xff8338EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.tags['3'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
