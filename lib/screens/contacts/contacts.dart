import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // json decode 등등 관리
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nemo_flutter/screens/mypage/profile_page.dart';
import 'package:provider/provider.dart';
import '../../models/contacts/user.dart';
import '../../providers/bottomBar.dart';
// import '../../tests/contacts/preferences.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  bool isSearching = false;
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  var nowId;
  List friends = [];
  List friendsStash = [];
  Map friendsData = {};
  final _controller = TextEditingController();
  getAllCards(id) async {
    try {
      var dio = Dio();
      Map nowfriendsData = {};
      Response response =
          await dio.get('http://34.64.217.3:3000/api/card/all/$id');
      if (response.statusCode == 200) {
        final json = response.data;

        json['cards'].forEach((e) {
          var friendId = e['user_id'];
          nowfriendsData[friendId] = User(
            imagePath:
                'https://storage.googleapis.com/nemo-bucket/${e['image']}',
            nickname: e['nickname'],
            introduction: e['intro'],
            tag: [
              '#${e['tag_1']}',
              '#${e['tag_2']}',
              '#${e['tag_3']}',
            ],
          );
        });

        setState(() {
          friends = List.from(json['friends'].reversed);
          friendsData = nowfriendsData;
          friendsStash = friends;
        });
        print('접속 성공!');
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      print('뭔가 에러가');
      return false;
    }
  }

  deleteFriend(target) async {
    try {
      var dio = Dio();
      Response response = await dio.get(
          'http://34.64.217.3:3000/api/friend/delete?id_1=$nowId&id_2=$target');
      if (response.statusCode == 200) {
        final json = response.data;
        setState(() {
          friends.remove(target);
          friendsData.remove(target);
        });
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      print('뭔가 에러가');
      return false;
    }
    // 친구 삭제하는 POST 요청 추가필요
  }

  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      nowId = int.parse(jsonDecode(userInfo)['user_id']);
    });
    await getAllCards(nowId);
  }

  searchContacts(text) {
    // 순서 유지되는지 확인하기
    setState(() {
      friends = friendsStash
          .where((x) => friendsData[x].nickname.startsWith(text))
          .toList();
    });
  }

  resetContacts() {
    setState(() {
      friends = friendsStash;
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
        appBar: isSearching
            ? AppBar(
                title: Padding(
                    padding: EdgeInsets.only(
                        top: 10, left: 22, right: 0, bottom: 15),
                    child: TextField(
                      controller: _controller,
                      onChanged: (text) async {
                        searchContacts(text);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                icon: Icon(Icons.clear),
                                color: Colors.black, //Color(0xff8338EC)
                                iconSize: 15,
                                onPressed: () {
                                  _controller.clear();
                                  resetContacts();
                                }),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                BorderSide(color: Colors.grey.shade100)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                BorderSide(color: Colors.grey.shade100)),
                      ),
                    )),
                toolbarHeight: 45,
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          isSearching = false;
                          resetContacts();
                        });
                      },
                      icon: Icon(
                        Icons.cancel,
                        size: 20,
                      ))
                ],
                automaticallyImplyLeading: false,
              )
            : AppBar(
                title: Text(
                  'NeMo',
                  style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                toolbarHeight: 45,
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        isSearching = true;
                      });
                    },
                  )
                ],
              ),
        body: ListView.separated(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.fromLTRB(25, 15, 25, 15), // 사진 크기 조절 1
            // shrinkWrap: false,
            physics: BouncingScrollPhysics(),
            itemCount: friends.length,
            itemBuilder: (c, i) {
              return InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => ProfilePage(
                              friendId: friends[i],
                              currIndex: 0,
                            ))),
                child: Slidable(
                  key: UniqueKey(),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return DialogUI(
                                    target: friends[i],
                                    deleteFriend: deleteFriend);
                              });
                        },
                        backgroundColor: Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.add_alert,
                        label: 'Delete',
                      )
                    ],
                  ),
                  child: Container(
                    // height: 500,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0), // 사진 크기 조절 2
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1.0,
                          offset: Offset(2, 4), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // add this
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          child: Image(
                            image: CachedNetworkImageProvider(
                                friendsData[friends[i]].imagePath),
                            width: double.infinity,
                            height: 235,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                              border:
                                  Border(top: BorderSide(color: Colors.black))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: double.infinity,
                                  height: 25,
                                  child: Center(
                                    child: ListView.separated(
                                        // shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        physics: ClampingScrollPhysics(),
                                        itemBuilder: (c, j) {
                                          if (j == 0) {
                                            return buildNickName(
                                                friendsData[friends[i]]
                                                    .nickname);
                                          } else if (j == 2) {
                                            return buildWhiteTag(
                                                friendsData[friends[i]]
                                                    .tag[j - 1]);
                                          } else {
                                            return buildPurPleTag(
                                                friendsData[friends[i]]
                                                    .tag[j - 1]);
                                          }
                                        },
                                        separatorBuilder: (c, k) =>
                                            SizedBox(width: 5),
                                        itemCount: 4),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                friendsData[friends[i]].introduction,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // SizedBox(height: 5),
                              // Row(
                              //   children: [
                              //     Container(
                              //       padding:
                              //           EdgeInsets.fromLTRB(7, 2, 7, 2),
                              //       decoration: BoxDecoration(
                              //         color: Color(0xff8338EC),
                              //         borderRadius:
                              //             BorderRadius.circular(10),
                              //       ),
                              //       child: Text(
                              //         friendsData[friends[i]].tag[0],
                              //         style: TextStyle(
                              //           color: Colors.white,
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),
                              //     Padding(
                              //         padding:
                              //             EdgeInsets.fromLTRB(0, 0, 8, 0)),
                              //     Container(
                              //       padding:
                              //           EdgeInsets.fromLTRB(7, 1, 7, 1),
                              //       decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius:
                              //             BorderRadius.circular(12),
                              //         border: Border.all(
                              //           width: 1.5,
                              //           color: Color(0xff8338EC),
                              //         ),
                              //       ),
                              //       child: Text(
                              //         friendsData[friends[i]].tag[1],
                              //         style: TextStyle(
                              //           color: Colors.black,
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),
                              //     Padding(
                              //         padding:
                              //             EdgeInsets.fromLTRB(0, 0, 8, 0)),
                              //     Container(
                              //       padding:
                              //           EdgeInsets.fromLTRB(7, 2, 7, 2),
                              //       decoration: BoxDecoration(
                              //         color: Color(0xff8338EC),
                              //         borderRadius:
                              //             BorderRadius.circular(10),
                              //       ),
                              //       child: Text(
                              //         friendsData[friends[i]].tag[2],
                              //         style: TextStyle(
                              //           color: Colors.white,
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, i) => SizedBox(height: 10)),
        bottomNavigationBar: context
            .read<BottomNavigationProvider>()
            .bottomNavigationBarClick(0, context),
      ),
    );
  }

  Widget buildNickName(nickname) => Container(
        child: Center(
          child: Text(
            nickname,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
  Widget buildPurPleTag(tagname) => Container(
        padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
        decoration: BoxDecoration(
          color: Color(0xff8338EC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1.5,
            color: Colors.grey.shade100,
          ),
        ),
        child: Center(
          child: Text(
            tagname.trim(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget buildWhiteTag(tagname) => Container(
        padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1.5,
            color: Color(0xff8338EC),
          ),
        ),
        child: Text(
          tagname,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

void doNothing(BuildContext context) {}

class DialogUI extends StatelessWidget {
  DialogUI({Key? key, this.target, this.deleteFriend}) : super(key: key);
  var target;
  var deleteFriend;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        alignment: Alignment.center,
        child: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('정말 삭제하시겠습니까?'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        deleteFriend(target);
                        Navigator.pop(context);
                      },
                      child: Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('No'),
                    )
                  ],
                )
              ],
            )));
  }
}
