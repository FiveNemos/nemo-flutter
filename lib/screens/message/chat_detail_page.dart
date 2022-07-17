import 'package:flutter/material.dart';
import '../../models/message/chat_message_model.dart';
import '../../tests/message/chat_user_test_data.dart';

class ChatDetailPage extends StatefulWidget {
  String name;
  String imageUrl;
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
  ChatDetailPage({required this.name, required this.imageUrl});
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  var inputData = TextEditingController();
  addMessage(name, text) {
    setState(() {
      messages_db[name]
          .add(ChatMessage(messageContent: text, messageType: 'sender'));
    });
  }
  // ScrollController _scrollController = new ScrollController();

  late ScrollController _controller;

  void _scrollDown() {
    _controller.animateTo(_controller.position.maxScrollExtent,
        duration: Duration(seconds: 1), curve: Curves.ease);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/contacts');
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.imageUrl),
                      maxRadius: 20,
                    ),
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
                          'Online',
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
              controller: _controller,
              itemCount: messages_db[widget.name].length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              // physics: NeverScrollableScrollPhysics(), // 이거 있으면 대화창 스크롤이 안됨
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment: (messages_db[widget.name][index].messageType ==
                            'receiver'
                        ? Alignment.topLeft
                        : Alignment.topRight),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (messages_db[widget.name][index].messageType ==
                                'receiver'
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
          ],
        ),
        bottomNavigationBar: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 45,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
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
                    onTap: () {
                      _scrollDown();
                    },
                    decoration: InputDecoration(
                        hintText: 'Write message...',
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none),
                    controller: inputData,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                // Send Button
                FloatingActionButton(
                  onPressed: () {
                    _scrollDown();
                    if (inputData.text.isNotEmpty) {
                      addMessage(widget.name, inputData.text);
                      inputData.clear();
                    }
                    // messages_db[widget.name].add(ChatMessage(messageContent: inputData.text, messageType: "sender"));
                  },
                  backgroundColor: Colors.blue,
                  elevation: 0,
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
