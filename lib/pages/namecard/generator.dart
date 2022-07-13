import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;

Future<dynamic> postNameCard
    (dynamic context, String nickname, Map tags, String introduction, Image userImage) async{
  final response = await http.post(
    Uri.parse('http://34.64.217.3:3000/api/card/create'),
      // headers: <String, String>{
      // "Content-Type": "multipart/form-data"
      // },
    body: {
      "user_id": "9999",
      "nickname": nickname,
      "tag_1": tags['0'],
      "tag_2": tags['1'],
      "tag_3": tags['2'],
      "intro": introduction,
      "image": userImage,
    },
  );
  if (response.statusCode == 201){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
              title: Text('저장완료'),
              content: Text('가입이 완료되었습니다.'),
              actions: [
                TextButton(
                  // textColor: Colors.black,
                  onPressed: (){
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text('확인'),
                )
              ]
          );});
  } else {
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text('저장실패'),
          content: Text('재시도하세요'),
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.star))
          ]
        );
      }
    );
    // throw Exception('명함 저장 실패');
  }
}



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
  var userImage = Image.asset('assets/grey_profile.png', fit: BoxFit.fill); //이건 파일형태가 아니군!

  saveName(String value){
    setState(() {
      nickname = value;
    });
  }

  saveTags(int num, String value){
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

  saveIntro(String value){
    setState(() {
      introduction = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        // FocusScopeNode currentFocus = FocusScope.of(context);
        // if (!currentFocus.hasPrimaryFocus){
        //   currentFocus.unfocus();
      FocusScope.of(context).unfocus();
    },
      child: Scaffold(
        appBar: AppBar(
          title: Text('명함 생성'),
          actions: [ElevatedButton(
            style: ElevatedButton.styleFrom(fixedSize: Size(40, 40)),
            child: Text('저장'),
              onPressed: (){
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

              )]
          ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NameCard(nickname: nickname, tags: tags, introduction: introduction, userImage: userImage),
              Container(
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10),),
                    nameSpace(nickname: nickname, saveName: saveName,),
                    Container(
                      width: 200,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: tagSpace(saveTags: saveTags, num: 1),
                            ),
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: tagSpace(saveTags: saveTags, num: 2),
                            ),
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: tagSpace(saveTags: saveTags, num: 3),
                            )
                          ]
                      ),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),),
                    introSpace(introduction: introduction, saveIntro: saveIntro,),
                    TextButton(
                      child: Text('사진 가져오기'),
                        // icon: Icon(Icons.add_box_rounded),
                        onPressed: () async {
                          var picker = ImagePicker();
                          var image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              userImage = Image.file(File(image.path), fit: BoxFit.fill);
                            });
                          }
                        }
                    ),
                  ],//children
              ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ElevatedButton(
          child: Text('메인 페이지로 이동'),
          onPressed: () {
            Navigator.pushNamed(context, '/');
            },

        )

      ),
    );
  }
}


class nameSpace extends StatefulWidget {
  nameSpace({Key? key, this.nickname, this.saveName,}) : super(key: key);
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
        constraints: BoxConstraints(minWidth: 200, maxWidth: 200, minHeight: 30, maxHeight: 30),
        labelText: '닉네임',
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
      // controller: controller,
      onChanged: (context) {
        if (controller.text != null) {
          setState(() {
            widget.nickname = controller.text;
          });
          // print(widget.nickname);
          // widget.saveName(controller.text);
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
      onChanged: (context) {
        if (controller.text != null){
          widget.saveTags(widget.num, controller.text);
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

  void _handleChange(){
    setState(() {
      widget.introduction = controller.text;
    });
  }

  @override
  void initState(){
    super.initState();
    controller.addListener(_handleChange);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
          constraints: BoxConstraints(minWidth: 200, maxWidth: 200, minHeight: 30, maxHeight: 100),
          labelText: '한줄소개',
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
        maxLines: 3,
        maxLength: 50,
        onChanged: (context) {
          if (controller.text != null) {
            _handleChange();
            print(widget.introduction);
            // setState(() {
            //   widget.introduction = controller.text;
            // });
            // widget.saveIntro(controller.text);
          }
        }
    );
  }
}

class NameCard extends StatefulWidget {
  NameCard({Key? key, this.nickname, this.tags, this.introduction, this.userImage}) : super(key: key);
  var nickname, tags, introduction, userImage;

  @override
  State<NameCard> createState() => _NameState();
}

class _NameState extends State<NameCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0),),
            Container(
              width: 100,
              height: 100,
              child: widget.userImage,
            ),
            Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 0),),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ItemTags(title: nickname),
                Text(widget.nickname,style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400)),
                Tags(
                  horizontalScroll: true, //이걸 해도 길어졌을 때 소용이 없음...
                  itemCount: 3,
                  itemBuilder: (int index){
                    return Tooltip(
                      // decoration: BoxDecoration(color: Color(0xffADD8E6)),
                      message: 'message',
                      child: ItemTags(
                          activeColor: Color(0xffADD8E6),
                          textActiveColor: Colors.black,
                          index: index,
                          title: widget.tags['${index+1}'].toString()
                      ),
                    );
                  },
                ),
                Text(widget.introduction, style: TextStyle(fontSize: 15)),
              ],
            )
          ], //children
        )
    );
  }
}







