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
import '../../providers/shimmerLoad.dart';
// import '../../tests/contacts/preferences.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  bool isSearching = false;
  bool isLoading = true;
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
        if (json == 'no friend') {
          setState(() {
            isLoading = false;
          });
        } else {
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
            isLoading = false;
          });
        }
        print('접속 성공!');
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      print('뭔가 에러가');
      setState(() {
        isLoading = false;
      });
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
    void _showDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            // title: new Text("TooK 가이드"),
            content: SingleChildScrollView(
              // height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                // alignment: Alignment.center,
                children: <Widget>[
                  Text('신고 및 유저 차단 방법을 설명드릴게요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Gamja',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  SizedBox(
                    height: 20,
                  ),
                  Text('1. 연락처에서 신고 및 차단하고자 하는 명함을 오른쪽으로 밉니다.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'dohyeon',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SizedBox(
                    height: 20,
                  ),
                  Text('2. 신고 및 차단하기 빨간색 버튼을 클릭합니다.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'dohyeon',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SizedBox(
                    height: 20,
                  ),
                  Text('3. 확인 버튼을 클릭해 신고를 접수하고, 차단합니다.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'dohyeon',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SizedBox(
                    height: 20,
                  ),
                  Text('신고 및 차단한 유저는 더이상 회원님께 보이지 않습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'dohyeon',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                      '위 과정 중 문제나 불편사항이 발생한다면, 언제든지 네모 고객센터 fivenemos@gmail.com으로 문의주세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'dohyeon',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ],
              ),
            ),
            // add text
            actions: <Widget>[
              ElevatedButton(
                child: Text('명함 밀어서 신고하기! 이해완료!',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontFamily: 'Dohyun')),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

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
                leadingWidth: 120,
                leading: ElevatedButton.icon(
                  onPressed: () {
                    _showDialog();
                  },
                  icon: Icon(
                    Icons.report,
                    size: 30,
                    color: Colors.red,
                  ),
                  label: Text(
                    '신고',
                    style: TextStyle(
                        fontFamily: 'dohyeon',
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
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
        body: isLoading
            ? Column(
                children: [
                  context.read<ShimmerLoadProvider>().shimmerForSharing(),
                  context.read<ShimmerLoadProvider>().shimmerForSharing(),
                ],
              )
            : friends.length > 0
                ? ListView.separated(
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
                                icon: Icons.report,
                                label: '신고 및 차단하기',
                              )
                            ],
                          ),
                          child: Container(
                            // height: 500,
                            margin:
                                EdgeInsets.fromLTRB(0, 0, 0, 0), // 사진 크기 조절 2
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 1.0,
                                  offset: Offset(
                                      2, 4), // changes position of shadow
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
                                      border: Border(
                                          top:
                                              BorderSide(color: Colors.black))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: double.infinity,
                                          height: 25,
                                          child: Center(
                                            child: ListView.separated(
                                                // shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics:
                                                    ClampingScrollPhysics(),
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
                    separatorBuilder: (context, i) => SizedBox(height: 10))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 200,
                        child: Center(
                          child: Text(
                              '보유한 명함이 없습니다. \n 공유페이지에서 TOOK으로 새 친구를 만나보세요!',
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
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
                Text(
                    '신고 및 차단은 철회할 수 없으며 신고 회원은 더이상 회원님에게 보이지 않습니다. \n\n 신고 및 차단하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Dohyun',
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
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
