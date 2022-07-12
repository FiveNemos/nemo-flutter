import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NameCardGenerator extends StatefulWidget {
  const NameCardGenerator({Key? key}) : super(key: key);

  @override
  State<NameCardGenerator> createState() => _NameCardGeneratorState();
}

class _NameCardGeneratorState extends State<NameCardGenerator> {
  var nickname = '닉네임';
  var tag1 = '태그1', tag2 = '태그2', tag3 = '태그3';
  var introduction = '한줄소개';
  var userImage = Image.asset('assets/grey_profile.png', fit: BoxFit.fill); //이건 파일형태가 아니군!

  saveName(String value){
    setState(() {
      nickname = value;
    });
  }

  saveTags(int num, String value){
    if (num == 1){
      setState(() {
        tag1 = value;
      });
    } else if (num == 2){
      setState(() {
        tag2 = value;
      });
    } else {
      setState(() {
        tag3 = value;
      });
    }
  }

  saveIntro(String value){
    setState(() {
      introduction = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('명함 생성'),
        actions: [IconButton(
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                        title: Text('저장완료'),
                        content: Text('가입이 완료되었습니다.'),
                        actions: [
                          FlatButton(
                            textColor: Colors.black,
                            onPressed: (){
                              Navigator.pushNamed(context, '/');
                            },
                            child: Text('확인'),
                          )
                        ]
                      );});
            },
            icon: Icon(Icons.save_rounded))]
        ),
      body: Center(
        child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Color(0xffe4bce8),
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
                Container(
                  width: 100,
                  height: 100,
                  child: userImage,
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: nameSpace(saveName: saveName),
                    ),
                    Row(
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
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: introSpace(saveIntro: saveIntro),
                    ),
                    // Text(String this.nickname), //이거해주세요... show value of var nickname
                    IconButton(
                        icon: Icon(Icons.add_box_rounded),
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
                  ],
                )
              ],
            )
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        child: Text('메인 페이지로 이동'),
        onPressed: () {
          Navigator.pushNamed(context, '/');
          },

      )

    );
  }
}


class nameSpace extends StatefulWidget {
  nameSpace({Key? key, this.saveName}) : super(key: key);
  var saveName;

  @override
  State<nameSpace> createState() => _nameSpaceState();
}

class _nameSpaceState extends State<nameSpace> {
  var controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: '',
        labelText: '닉네임 *',
      ),
      controller: controller,
      onChanged: (String value) {
        widget.saveName(controller.text);
      },
      // validator: (String? value) {
      //   return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
      // },
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
        hintText: '',
        labelText: '태그 *',
      ),
      controller: controller,
      onChanged: (String value) {
        widget.saveTags(widget.num, controller.text);
      },
    );
  }
}

class introSpace extends StatefulWidget {
  introSpace({Key? key, this.saveIntro}) : super(key: key);
  var saveIntro;

  @override
  State<introSpace> createState() => _introSpaceState();
}

class _introSpaceState extends State<introSpace> {
  var controller=  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: const InputDecoration(
        hintText: '',
        labelText: '한줄소개 *',
      ),
        controller: controller,
        onChanged: (String value) {
        widget.saveIntro(controller.text);
    },
    );
  }
}








// class NameCardGenerator extends StatelessWidget {
//   const NameCardGenerator({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         height: 200,
//         width: 300,
//         child: Card(
//           child: GestureDetector(
//             onTap: () {
//               debugPrint('Card tapped.');
//             },
//             child: Row(
//               children: [
//                 Container(
//                     width: 80,
//                     height: 80,
//                     child:Image.asset('assets/grey_profile.png')),
//                 SizedBox(
//                   width: 160,
//                   height: 180,
//                   child: Column(
//                       children: [
//                         TextField(),
//                         TextField(),
//                         TextField(),
//                       ]
//                   )
//
//                 )
//               ]
//             )
//           ),
//         ),
//       )
//
//     );
//   }
// }




//
// class NameCardGenerator extends StatelessWidget {
//   const NameCardGenerator({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//
// child: Card(
//
//   child: Row(
//     children: <Widget>[
//       Image.asset('asset/grey_profile.png'),
//       const ListTile(
//         leading: Icon(Icons.album),
//         title: Text('Nickname'),
//         subtitle: Text('Brief Introduction'),
//       ),
// Row(
//   mainAxisAlignment: MainAxisAlignment.end,
//   children: <Widget>[
//     TextButton(
//       child: const Text('BUY TICKETS'),
//       onPressed: () {/* ... */},
//     ),
//     const SizedBox(width: 8),
//     TextButton(
//       child: const Text('LISTEN'),
//       onPressed: () {/* ... */},
//     ),
//     const SizedBox(width: 8),
//   ],
// ),
//           ],
//         ),
//       ),
//     );
//   }
// }