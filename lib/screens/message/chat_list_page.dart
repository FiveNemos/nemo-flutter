import 'package:flutter/material.dart';
import '../../models/message/chatrooms.dart';
import '../../widgets/message/conversation_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  var loginID;
  List<ChatRooms> original_chatUsers = [
    ChatRooms(
        chatroomID: 1,
        friendID: 10,
        friendName: '주비 테스트',
        intro: '주비입니다 테스트용 계정. 채팅 1번방',
        friendImage:
            'http://34.64.217.3:3000/static/1658624809850-image_picker1133892711702179292.png',
        lastMsgTime: '1 min'),
    ChatRooms(
        chatroomID: 2,
        friendID: 10,
        friendName: '주비 테스트',
        intro: '주비입니다 테스트용 계정. 채팅 2번방',
        friendImage:
            'http://34.64.217.3:3000/static/1658624809850-image_picker1133892711702179292.png',
        lastMsgTime: '1 min'),
  ]; // 이걸 DB에서 받아오는거로 바꾸면 될듯

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
          print("뭐냐고요");
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
                      intro: chatUsers[index].intro,
                      friendImage: chatUsers[index].friendImage,
                      lastMsgTime: chatUsers[index].lastMsgTime,
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
