import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/message/chatrooms.dart';
import '../../widgets/message/conversation_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

const BASE_URL = 'http://34.64.217.3:3000/static/';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  var loginID;

  dateToText(DateTime msgtime) {
    Duration diff = DateTime.now().difference(msgtime);
    if (diff.inDays > 0) {
      if (diff.inDays > 7) {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
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

  getChatRooms(id) async {
    try {
      var dio = Dio();
      Response response = await dio
          .get('http://34.64.217.3:3000/api/chatroom/list?user_id=$id');
      if (response.statusCode == 200) {
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
          DateTime lastmsgtime = DateTime.parse(e[3]);
          ChatRooms nowRoom = ChatRooms(
              chatroomID: roomId,
              friendID: friendId,
              friendName: nowFriendData['nickname'],
              intro: nowFriendData['intro'],
              friendImage: BASE_URL + nowFriendData['image'],
              lastMsgTime: lastmsgtime,
              lastMsgText: e[4]);
          temp.add(nowRoom);
        });
        setState(() {
          // temp를 시간순에 따라서 sort하기
          temp.sort((a, b) => a.lastMsgTime.compareTo(b.lastMsgTime));
          original_chatUsers = temp;
        });
        print('접속 성공!');
      } else {
        print('error');
        return false;
      }
    } on DioError catch (e) {
      print('뭔가 에러가');
      final errorjson = jsonDecode(e.response.toString());
      print(errorjson);
      return false;
    }
  }

  List<ChatRooms> original_chatUsers = []; // 이걸 DB에서 받아오는거로 바꾸면 될듯

  List chatUsers = [];
  resetConversation() {
    setState(() {
      chatUsers = original_chatUsers; // DB에서 받아오는 코드 '여기에도' 넣기
    });
  }

  searchConversation(text) {
    var temp = [];
    for (var e in original_chatUsers) {
      if (e.friendName.startsWith(text)) {
        // temp.add(e);
        if (e.friendID != loginID) {
          print('뭐냐고요');
          print(e.friendID);
          print(loginID);
          temp.add(e);
        }
      }
    }
    setState(() {
      chatUsers = temp;
    });
  }

  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      loginID = int.parse(jsonDecode(userInfo)['user_id']);
    });
    await getChatRooms(loginID);
    resetConversation();
    // await getAllCards(nowId);
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  // @override
  // Widget buildSuggestions(BuildContext context) {
  //   List<String> suggestions = [
  //     'Brazil',
  //     'China',
  //     'India',
  //     'Russia',
  //     'USA',
  //   ];
  //   return ListView.builder(
  //     itemCount: 5,
  //     itemBuilder: (context, index) {
  //       final suggestion = suggestions[index];
  //       return ListTile(
  //         title: Text(suggestion),
  //         onTap: () {},
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Conversations',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 2),
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey[200],
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.add,
                              color: Colors.pink,
                              size: 20,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              'Add New',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: TextField(
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      searchConversation(text);
                    } else {
                      resetConversation();
                    }
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
              ListView.builder(
                itemCount: chatUsers.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 16),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ConversationList(
                      chatroomID: chatUsers[index].chatroomID,
                      loginID: loginID,
                      friendID: chatUsers[index].friendID,
                      friendName: chatUsers[index].friendName,
                      lastMsgText: chatUsers[index].lastMsgText,
                      friendImage: BASE_URL + chatUsers[index].friendImage,
                      lastMsgTime: dateToText(chatUsers[index].lastMsgTime),
                      isMessageRead: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
