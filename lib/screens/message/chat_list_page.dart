import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/message/chatrooms.dart';
import '../../widgets/message/conversation_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';

const BASE_URL = 'https://storage.googleapis.com/nemo-bucket/';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  int? loginID;

  final StreamController _streamController = StreamController();
  Timer? _timer;
  List<ChatRooms> original_chatUsers = []; // 이걸 DB에서 받아오는거로 바꾸면 될듯
  List chatUsers = [];
  String searchText = '';
  bool isLoading = true;

  dateToText(DateTime msgtime) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    Duration diff = dateFormat
        .parse(dateFormat.format(DateTime.now()))
        .difference(dateFormat.parse((dateFormat.format(msgtime))));
    print(msgtime);
    print(DateTime.now());
    if (diff.inDays > 0) {
      if (diff.inDays > 7) {
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        return dateFormat.format(msgtime);
      } else {
        return '${diff.inDays}일 전';
      }
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}분 전';
    } else {
      return '방금';
    }
  }

  Future getData(id) async {
    try {
      var dio = Dio();
      Response response = await dio
          .get('http://34.64.217.3:3000/api/chatroom/list?user_id=$id');
      if (response.data == 'false') {
        setState(() {
          isLoading = false;
        });
      }
      if (response.statusCode == 200 && response.data != 'false') {
        print('responsedata : ${response.data}');
        final jsonData = response.data;
        var roomData = jsonData['chatroom'];
        var friendData = jsonData['data'];
        Map friendDataMap = {};
        friendData[0].forEach((e) {
          print(e);
          friendDataMap[e['user_id']] = e;
        });
        List<ChatRooms> temp = [];

        roomData.forEach((e) {
          var roomId = e[0];
          int friendId = json.decode(e[2]).where((x) => x != id).toList()[0];
          var nowFriendData = friendDataMap[friendId];
          DateTime lastmsgtime = DateTime.parse(e[3]).toLocal();
          ChatRooms nowRoom = ChatRooms(
              chatroomID: roomId,
              friendID: friendId,
              friendName: nowFriendData['nickname'],
              intro: nowFriendData['intro'],
              friendImage: BASE_URL + nowFriendData['image'],
              lastMsgTime: lastmsgtime,
              lastMsgText: e[4],
              notReadCnt: nowFriendData['not_read_cnt']);

          temp.add(nowRoom);
        });
        setState(() {
          // temp를 시간순에 따라서 sort하기
          temp.sort((a, b) => b.lastMsgTime.compareTo(a.lastMsgTime));
          original_chatUsers = temp;
        });
        print('접속 성공!');
        _streamController.add(temp);
        setState(() {
          isLoading = false;
        });
      } else {
        print('error');
        return false;
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
      print('뭔가 에러가');
      final errorjson = jsonDecode(e.response.toString());
      print(errorjson);
      return false;
    }
  }

  // resetConversation() {
  //   setState(() {
  //     // chatUsers = original_chatUsers; // DB에서 받아오는 코드 '여기에도' 넣기
  //     chatUsers.clear();
  //   });
  // }

  searchConversation(text) {
    // var searchList = [];
    // for (var e in original_chatUsers) {
    //   if (e.friendName.startsWith(text)) {
    //     // temp.add(e);
    //     if (e.friendID != loginID) {
    //       print('뭐냐고요');
    //       print(e.friendID);
    //       print(loginID);
    //       searchList.add(e);
    //     }
    //   }
    // }
    setState(() {
      searchText = text;
    });
  }

  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      loginID = int.parse(jsonDecode(userInfo)['user_id']);
      _timer = Timer.periodic(
          Duration(milliseconds: 800), (timer) => getData(loginID));
    });
    await getData(loginID);
    // await getAllCards(nowId);
  }

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  @override
  void dispose() {
    //cancel the timer
    if (_timer!.isActive) _timer!.cancel();
    // setState(() {
    //   _timer!.cancel();
    // });
    super.dispose();
  }

  @override
  void deactivate() {
    // setState(() {
    //   _timer!.cancel();
    // });
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'NeMo',
              style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // SafeArea(
                //   child: Padding(
                //     padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: <Widget>[
                //         Text(
                //           'Conversations',
                //           style: TextStyle(
                //               fontSize: 24, fontWeight: FontWeight.bold),
                //         ),
                //         Container(
                //           padding: EdgeInsets.only(
                //               left: 8, right: 8, top: 2, bottom: 2),
                //           height: 30,
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(30),
                //             color: Colors.grey[200],
                //           ),
                //           child: Row(
                //             children: <Widget>[
                //               Icon(
                //                 Icons.add,
                //                 color: Colors.pink,
                //                 size: 20,
                //               ),
                //               SizedBox(
                //                 width: 2,
                //               ),
                //               Text(
                //                 'Add New',
                //                 style: TextStyle(
                //                     fontSize: 14, fontWeight: FontWeight.w800),
                //               ),
                //             ],
                //           ),
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: TextField(
                    onChanged: (text) {
                      searchConversation(text);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.all(8),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade100)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade100)),
                    ),
                  ),
                ),
                isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey,
                          highlightColor: Color(0xff8338EC),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: 10,
                            itemBuilder: (c, i) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                    leading: Icon(Icons.person, size: 50.0),
                                    title: SizedBox(
                                      height: 20.0,
                                      child: Container(
                                        color: Colors.teal,
                                      ),
                                    )),
                              );
                            },
                          ),
                        ),
                      )
                    : StreamBuilder(
                        stream: _streamController.stream,
                        initialData: [],
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          // print("snapshot");
                          // print(snapshot.data);
                          if (snapshot.hasData) {
                            chatUsers = snapshot.data;
                            if (chatUsers.isEmpty) {
                              return Container(
                                alignment: Alignment.center,
                                height: 500,
                                child: Text(
                                    '대화 내역이 없습니다. \n 명함을 교환한 친구에게 메시지를 보내보세요!',
                                    textAlign: TextAlign.center),
                              );
                            }
                            chatUsers = chatUsers
                                .where(
                                    (x) => x.friendName.startsWith(searchText))
                                .toList();

                            return ListView.builder(
                              itemCount: chatUsers.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.only(top: 16),
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                print(chatUsers[index]);
                                return ConversationList(
                                    chatroomID: chatUsers[index].chatroomID,
                                    loginID: loginID!,
                                    friendID: chatUsers[index].friendID,
                                    friendName: chatUsers[index].friendName,
                                    lastMsgText: chatUsers[index].lastMsgText,
                                    friendImage: chatUsers[index].friendImage,
                                    lastMsgTime: dateToText(
                                        chatUsers[index].lastMsgTime),
                                    notReadCnt: chatUsers[index].notReadCnt);
                              },
                            );
                          } else {
                            return Container(
                              alignment: Alignment.center,
                              height: 200,
                              child: Text('로딩 중입니다 :)',
                                  textAlign: TextAlign.center),
                            );
                          }
                        })
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.contacts),
                  label: '연락처',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: '지도',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.share),
                  label: '공유',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: '메시지',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '마이페이지',
                ),
              ],
              currentIndex: 3,
              onTap: (int nextIndex) {
                if (nextIndex == 3) {
                  return;
                }
                setState(() {
                  _timer!.cancel();
                });
                switch (nextIndex) {
                  case 0:
                    Navigator.pushNamed(context, '/contacts');
                    break;
                  case 1:
                    Navigator.pushNamed(context, '/map');
                    break;
                  case 2:
                    Navigator.pushNamed(context, '/sharing');
                    break;
                  case 3:
                    Navigator.pushNamed(context, '/message');
                    break;
                  case 4:
                    Navigator.pushNamed(context, '/mypage');
                    break;
                }
              })),
    );
  }
}
