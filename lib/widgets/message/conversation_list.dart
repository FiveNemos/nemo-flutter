import 'package:flutter/material.dart';
import '../../screens/message/chat_detail_page.dart';

class ConversationList extends StatefulWidget {
  var chatroomID;
  int loginID;
  int friendID;
  String friendName;
  String intro;
  String friendImage;
  String lastMsgTime;
  bool isMessageRead;
  ConversationList(
      {required this.chatroomID,
      required this.loginID,
      required this.friendID,
      required this.friendName,
      required this.intro,
      required this.friendImage,
      required this.lastMsgTime,
      required this.isMessageRead});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatScreen(
              chatroomID: widget.chatroomID,
              loginID: widget.loginID,
              friendID: widget.friendID,
              friendName: widget.friendName,
              friendImage: widget.friendImage);
        }));
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.friendImage),
                    // backgroundImage: AssetImage('${widget.imageUrl}'),
                    maxRadius: 30,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.friendName,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.intro,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: widget.isMessageRead
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.lastMsgTime, // 현재 시간을 계산해서, 'now' '2 hr' '8 Jul' 등으로 바꿔주기
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.isMessageRead
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
