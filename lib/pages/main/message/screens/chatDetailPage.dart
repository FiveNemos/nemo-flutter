import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:nemo_flutter/pages/messages/stores/storeMessage.dart';
import '../models/chatMessageModel.dart';

class ChatDetailPage extends StatefulWidget{
  String name;
  String imageUrl;
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
  ChatDetailPage({required this.name,required this.imageUrl});

}

class _ChatDetailPageState extends State<ChatDetailPage> {
  var inputData = TextEditingController();
  addMessage(name, text){
    setState((){
      messages_db[name].add(ChatMessage(messageContent: text, messageType: "sender"));
    });
  }
  // Map messages_db = {
  //   "Sanori": [
  //     ChatMessage(messageContent: "안녕하세요", messageType: "receiver"),
  //     ChatMessage(messageContent: "잘하고 계신가요 ㅎㅎ ", messageType: "receiver"),
  //     ChatMessage(messageContent: "앗 코치님! 플러터 하고 있어요. 금방 하겠죠..? ", messageType: "sender"),
  //     ChatMessage(messageContent: "예... 뭐 그럴수도 있겠다", messageType: "receiver"),
  //     ChatMessage(messageContent: "감... 감사합니다^^", messageType: "sender"),
  //   ],
  //   "Opjoobe": [
  //     ChatMessage(messageContent: "안녕하세요 주형님", messageType: "sender"),
  //     ChatMessage(messageContent: "앗 리더님! 친히 연락을 다 주시다니요", messageType: "receiver"),
  //     ChatMessage(messageContent: "농구 한판 하실래요 ?", messageType: "receiver"),
  //   ],
  //   "Jocy": [
  //     ChatMessage(messageContent: "안녕하세요 현욱님", messageType: "sender"),
  //     ChatMessage(messageContent: "네 안녕하세요~", messageType: "receiver"),
  //     ChatMessage(messageContent: "커피 한잔 하실래요 ?", messageType: "receiver"),
  //   ],
  //   "Jessy": [
  //     ChatMessage(messageContent: "안녕하세요 현주님", messageType: "sender"),
  //     ChatMessage(messageContent: "일어나셨나요 ?", messageType: "sender"),
  //     ChatMessage(messageContent: "현주님.....?", messageType: "sender"),
  //     ChatMessage(messageContent: "님..?", messageType: "sender"),
  //   ],
  //   "Chani": [
  //     ChatMessage(messageContent: "안녕하세요 찬익님", messageType: "sender"),
  //     ChatMessage(messageContent: "블루베리 가자구요?", messageType: "receiver"),
  //     ChatMessage(messageContent: "좋~죠~", messageType: "sender"),
  //   ],
  //   "Krafton": [
  //     ChatMessage(messageContent: "안녕하세요 의장님:) 저희 발표 혹시..", messageType: "sender"),
  //     ChatMessage(messageContent: "내가 말했지", messageType: "receiver"),
  //     ChatMessage(messageContent: "니 인생은 너꺼야!!! 운영진 신경쓰지마!!", messageType: "receiver"),
  //     ChatMessage(messageContent: "알겠어?!!", messageType: "receiver"),
  //   ],
  //   "고니고니": [
  //     ChatMessage(messageContent: "의장님께 채팅보내보기", messageType: "sender"),
  //     ChatMessage(messageContent: "계란 2주내로 먹기", messageType: "sender"),
  //   ],
  //   "Sparta": [
  //     ChatMessage(messageContent: "안녕하세요 성곤님", messageType: "receiver"),
  //     ChatMessage(messageContent: "대표님 안녕하세요!", messageType: "sender"),
  //     ChatMessage(messageContent: "디스 이즈 스파르타 !!!", messageType: "receiver"),
  //   ],
  // };
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.imageUrl
                       ),
                    maxRadius: 20,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          "Online",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.settings,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            ListView.builder(
              itemCount: messages_db[widget.name].length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              // physics: NeverScrollableScrollPhysics(), // 이거 있으면 대화창 스크롤이 안됨
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment: (messages_db[widget.name][index].messageType == "receiver"
                        ? Alignment.topLeft
                        : Alignment.topRight),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (messages_db[widget.name][index].messageType == "receiver"
                            ? Colors.grey.shade200
                            : Colors.blue[200]),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        messages_db[widget.name][index].messageContent,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "Write message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                        controller: inputData,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        if (inputData.text.isNotEmpty) {
                          addMessage(widget.name, inputData.text);
                          inputData.clear();
                        }
                        // messages_db[widget.name].add(ChatMessage(messageContent: inputData.text, messageType: "sender"));
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.blue,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}