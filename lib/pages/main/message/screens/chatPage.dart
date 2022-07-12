import 'package:flutter/material.dart';
import '../models/chatUserModel.dart';
import '../widgets/conversationList.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatUsers> chatUsers = [
    ChatUsers(text: "고니고니", secondaryText: "캣홀릭 오타쿠", image: "https://ca.slack-edge.com/T01FZU4LB4Y-U038SKSQH0D-5494a00d9938-512", time: "Now"),
    ChatUsers(text: "Opjoobe", secondaryText: "Ball is Life", image: "https://ca.slack-edge.com/T01FZU4LB4Y-U038VG8TD5H-2cdff7f10831-512", time: "3h"),
    ChatUsers(text: "Jessy", secondaryText: "Just Dance", image: "https://ca.slack-edge.com/T01FZU4LB4Y-U038NSLLYUE-61acb0b06e68-512", time: "5h"),
    ChatUsers(text: "Jocy", secondaryText: "Coffee Coffee", image: "https://ca.slack-edge.com/T01FZU4LB4Y-U038NSL7XAA-29c3e7232b89-512", time: "8 Jul"),
    ChatUsers(text: "Chani", secondaryText: "PingPong is Life", image: "https://ca.slack-edge.com/T01FZU4LB4Y-U038XSFUSMS-5562753ddde3-512", time: "6 Jul"),
    ChatUsers(text: "Krafton", secondaryText: "니 인생은 너꺼야!", image: "https://ca.slack-edge.com/T01FZU4LB4Y-U01GQQQGCBX-64f84f2f3f49-512", time: "30 Jun"),
    ChatUsers(text: "Sanori", secondaryText: "정글러버", image: "https://ca.slack-edge.com/T01FZU4LB4Y-U024206FLQM-239a518483a5-512", time: "28 Jun"),
    ChatUsers(text: "Sparta", secondaryText: "TEAM SPARTA", image: "https://ca.slack-edge.com/T01FZU4LB4Y-U01F70TFLCV-c33569d65252-512", time: "2 Jun"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16,right: 16,top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Conversations",style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                    Container(
                      padding: EdgeInsets.only(left: 8,right: 8,top: 2,bottom: 2),
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.add, color: Colors.pink, size: 20,),
                          SizedBox(width: 2,),
                          Text("Add New",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800),),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16,left: 16,right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: Colors.grey.shade100
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: Colors.grey.shade100
                      )
                  ),
                ),
              ),
            ),
            ListView.builder(
              itemCount: chatUsers.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                return ConversationList(
                  name: chatUsers[index].text,
                  messageText: chatUsers[index].secondaryText,
                  imageUrl: chatUsers[index].image,
                  time: chatUsers[index].time,
                  isMessageRead: (index == 0 || index == 3)?true:false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
