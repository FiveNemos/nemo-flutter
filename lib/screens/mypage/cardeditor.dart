import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../models/mypage/user.dart';
import '../sharing/sharing.dart';

const BASE_URL = 'http://34.64.217.3:3000/static/';

Map<String, int> CHANGED = {
  'nickname': 0,
  'tags': 0,
  'introduction': 0,
  'userImage': 0,
  'tagImage1': 0,
  'tagImage2': 0,
  'tagImage3': 0,
  'detailTitle': 0,
  'detailContent': 0
};

Future<dynamic> updateNameCard(
  dynamic context,
  nowID,
  String nickname,
  Map tags,
  introduction,
  File userImage,
  File tagImage1,
  File tagImage2,
  File tagImage3,
  String detailTitle,
  String detailContent,
) async {
  print('nowID : $nowID');
  if (userImage == null) {
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
    print('http post 요청 들어옴');
    var uri = Uri.parse('http://34.64.217.3:3000/api/card/update');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(
        {'Content-Type': 'multipart/form-data; boundary=----myboundary'});
    if (CHANGED['userImage'] == 1) {
      request.files
          .add(await http.MultipartFile.fromPath('image', userImage.path));
    }
    if (CHANGED['tagImage1'] == 1) {
      request.files
          .add(await http.MultipartFile.fromPath('tag_img_1', tagImage1.path));
      print(await http.MultipartFile.fromPath('tag_img_1', tagImage1.path));
    }
    if (CHANGED['tagImage2'] == 1) {
      request.files
          .add(await http.MultipartFile.fromPath('tag_img_2', tagImage2.path));
    }
    if (CHANGED['tagImage3'] == 1) {
      request.files
          .add(await http.MultipartFile.fromPath('tag_img_3', tagImage3.path));
    }

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

    if (response.statusCode == 200) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('수정완료'),
                content: Text('수정이 완료되었습니다.'),
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

class CardEditor extends StatefulWidget {
  const CardEditor({Key? key}) : super(key: key);

  @override
  State<CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  var user;
  static final storage = FlutterSecureStorage();
  var userInfo = '';
  var nowId;
  /* cardgenerator */
  var nickname;
  var tags;
  var introduction;
  dynamic userImage;
  dynamic tagImage1;
  dynamic tagImage2;
  dynamic tagImage3;
  var detailTitle;
  var detailContent;

  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      nowId = int.parse(jsonDecode(userInfo)['user_id']);
    });
    print('now: $nowId');
    await getCard(nowId);
    await setEverything(user);
    // print(nowId);
  }

  getCard(id) async {
    print('http://34.64.217.3:3000/api/card/$id');
    try {
      var dio = Dio();
      Response response = await dio.get('http://34.64.217.3:3000/api/card/$id');
      // Response response2 = await dio.get('http://34.64.217.3:3000/api/card/99'); // 실험
      print('response.data.runtimeType = ${response.runtimeType}');
      if (response.statusCode == 200) {
        final json = response.data;
        setState(() {
          user = UserProfile(
            imagePath: json['image'],
            nickname: json['nickname'],
            introduction: json['intro'],
            title: json['detail_title'], // title로 변경 필요
            about: json['detail_content'], // about로 변경 필요
            image1: BASE_URL + json['tag_img_1'],
            image2: BASE_URL + json['tag_img_2'],
            image3: BASE_URL + json['tag_img_3'],
            tag1: json['tag_1'],
            tag2: json['tag_2'],
            tag3: json['tag_3'],
            image: [
              BASE_URL + json['tag_img_1'],
              BASE_URL + json['tag_img_2'],
              BASE_URL + json['tag_img_3'],
            ],
            tag: [
              json['tag_1'],
              json['tag_2'],
              json['tag_3'],
            ],
          );
        });
        print('json : $json');
        print('image1: ${user.image1}');
        print(json['image']);
        return true;
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  setEverything(UserProfile user) {
    setState(() {
      nickname = user.nickname;
      tags = {'1': user.tag1, '2': user.tag2, '3': user.tag3};
      introduction = user.introduction;
      userImage = File(user.imagePath);
      // print(user.imagePath);
      tagImage1 = File(user.image1);
      tagImage2 = File(user.image2);
      tagImage3 = File(user.image3);
      detailTitle = user.title;
      detailContent = user.about;
      CHANGED.forEach((key, value) {
        CHANGED[key] = 0;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
    // print('now: $nowId');
    // getCard(nowId);
    // setEverything(user);
  }

  saveUserImage(File file) {
    setState(() {
      userImage = file;
      CHANGED['userImage'] = 1;
    });
  }

  saveTagImage(int num, File picture) {
    setState(() {
      if (num == 1) {
        tagImage1 = picture;
        CHANGED['tagImage1'] = 1;
      } else if (num == 2) {
        tagImage2 = picture;
        print(tagImage2.runtimeType);
        CHANGED['tagImage2'] = 1;
      } else {
        tagImage3 = picture;
        CHANGED['tagImage3'] = 1;
      }
    });
    print('CHANGED changed: $CHANGED');
  }

  saveName(String value) {
    setState(() {
      nickname = value;
      CHANGED['nickname'] = 1;
    });
  }

  saveTags(int num, String value) {
    setState(() {
      tags['$num'] = value;
      CHANGED['tags'] = 1;
    });
  }

  saveIntro(String value) {
    setState(() {
      introduction = value;
      CHANGED['introduction'] = 1;
    });
  }

  saveDetailTitle(String value) {
    setState(() {
      detailTitle = value;
      CHANGED['detailTitle'] = 1;
    });
  }

  saveDetailContent(String value) {
    setState(() {
      detailContent = value;
      CHANGED['detailContent'] = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Container(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text('명함 수정'),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(fixedSize: Size(40, 40)),
                    child: Text('저장'),
                    onPressed: () {
                      updateNameCard(
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
                        saveUserImage: saveUserImage,
                        user: user,
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 25)),
                      SizedBox(
                        width: 200,
                        height: 34,
                        child: NameSpace(
                            nickname: nickname, saveName: saveName, user: user),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                      SizedBox(
                        height: 34,
                        child: IntroSpace(
                            introduction: introduction,
                            saveIntro: saveIntro,
                            user: user),
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
                                    user: user,
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
                                    user: user,
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
                                    user: user,
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
                          )
                        ],
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (c, i) {
                            return SizedBox(
                              width: 100,
                              child: TagSpace(
                                  saveTags: saveTags, num: i + 1, user: user),
                            );
                          },
                          separatorBuilder: (c, i) => SizedBox(width: 10),
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                      SizedBox(
                        height: 35,
                        child: TextField(
                          decoration: InputDecoration(
                            // labelText: 'title',
                            hintText: detailTitle,
                            hintStyle: TextStyle(fontSize: 13),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Color(0xff8338EC),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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
                          // labelText: 'details',
                          labelStyle: TextStyle(fontSize: 12),
                          hintText: detailContent,
                          hintStyle: TextStyle(fontSize: 12),
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
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      );
    }
  }
}

class imageSpace extends StatefulWidget {
  imageSpace(
      {Key? key,
      this.saveTagImage,
      this.num,
      this.tagImage1,
      this.tagImage2,
      this.tagImage3,
      this.user})
      : super(key: key);
  var saveTagImage;
  var num;
  var tagImage1, tagImage2, tagImage3;
  var user;

  @override
  State<imageSpace> createState() => _imageSpaceState();
}

class _imageSpaceState extends State<imageSpace> {
  @override
  Widget build(BuildContext context) {
    if (widget.num == 1) {
      return InkWell(
        child: (CHANGED['tagImage${widget.num}'] == 1)
            ? Image.file(widget.tagImage1, fit: BoxFit.cover)
            : Image.network(widget.user.image[widget.num - 1],
                fit: BoxFit.cover),
        // : Image.network(widget.tagImage1.path), //이것도 됨
        // : Image.file(File(
        //     'http://34.64.217.3:3000/static/${widget.user.imagePath}')),
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
        child: (CHANGED['tagImage${widget.num}'] == 1)
            ? Image.file(widget.tagImage2, fit: BoxFit.cover)
            : Image.network(widget.user.image[widget.num - 1],
                fit: BoxFit.cover),
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
        child: (CHANGED['tagImage${widget.num}'] == 1)
            ? Image.file(widget.tagImage3, fit: BoxFit.cover)
            : Image.network(widget.user.image[widget.num - 1],
                fit: BoxFit.cover),
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
  NameSpace({Key? key, this.nickname, this.saveName, this.user})
      : super(key: key);
  var nickname, saveName;
  var user;

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
        // labelText: '닉네임',
        labelStyle: TextStyle(fontSize: 12),
        hintText: widget.nickname,
        hintStyle: TextStyle(fontSize: 12),
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
  TagSpace({Key? key, this.saveTags, this.num, this.user}) : super(key: key);
  var saveTags;
  var num;
  var user;

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
        // labelText: '태그',
        labelStyle: TextStyle(fontSize: 12),
        hintText: '${widget.user.tag[widget.num - 1]}',
        hintStyle: TextStyle(fontSize: 12),
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
  IntroSpace({Key? key, this.introduction, this.saveIntro, this.user})
      : super(key: key);
  var introduction, saveIntro;
  var user;

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
          // labelText: '한줄소개',
          labelStyle: TextStyle(fontSize: 12),
          hintText: widget.introduction,
          hintStyle: TextStyle(fontSize: 12),
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
  NameCard(
      {Key? key,
      this.nickname,
      this.tags,
      this.introduction,
      this.userImage,
      this.saveUserImage,
      this.user})
      : super(key: key);

  var nickname, tags, introduction;
  dynamic userImage;
  var saveUserImage;
  var user;

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
                decoration: BoxDecoration(color: Color(0xffE6E6FA)),
                child: InkWell(
                  onTap: () async {
                    var picker = ImagePicker();
                    var image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      widget.saveUserImage(File(image.path));
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                    child: (CHANGED['userImage'] == 1)
                        ? Image.file(widget.userImage)
                        : Image.network(BASE_URL + widget.userImage.path,
                            fit: BoxFit.fill),
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
