import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../models/message/chatmodel.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  var chatroomID;
  int loginID;
  int friendID;
  String friendName;
  String friendImage;

  ChatScreen({
    Key? key,
    required this.chatroomID,
    required this.loginID,
    required this.friendID,
    required this.friendName,
    required this.friendImage,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  getChatMessages(chatroomid) async {
    try {
      var dio = Dio();
      Response response = await dio.get(
          'http://34.64.217.3:3000/api/chatroom/message?room_id=$chatroomid');
      if (response.statusCode == 200) {
        final jsonData = response.data;
        List<ChatModel> temp = [];
        jsonData.forEach((e) {
          var nowtime = DateTime.parse(e['sendat']);
          print(nowtime.runtimeType);
          var realnow = DateTime.now();
          print(realnow.runtimeType);
          Duration diff = realnow.difference(nowtime);
          print(diff.inMinutes);
          print(diff.inHours);
          print(diff.inDays);
          ChatModel thisMsg = ChatModel(
              chatroomID: widget.chatroomID,
              senderID: e['sender'],
              receiverID: 0,
              sentAt: e['sendat'],
              messagetext: e['messagetext']);
          temp.add(thisMsg);
        });
        setState(() {
          _messages = temp;
        });
        print('접속 성공!');
      } else {
        print('error');
        return false;
      }
    } on DioError catch (e) {
      final errorjson = jsonDecode(e.response.toString());
      print(errorjson);
      return false;
    }
  }

  final List<ChatModel> _samplemsg = [
    // ChatModel(
    //     chatroomID: 1,
    //     senderID: 10,
    //     sentAt: '2022-07-25 11:14',
    //     message: '주비 테스트 계정입니다 1번방'),
    // ChatModel(
    //     chatroomID: 2,
    //     senderID: 10,
    //     sentAt: '2022-07-25 11:14',
    //     message: '주비 테스트 계정입니다 2번방'),
    // 여기에 DB에서 긁어와서 setState(_message.add)하게 바꾸기
  ];
  List<ChatModel> _messages = []; // 여기에 DB에서 긁어와서 setState(_message.add)하게 바꾸기

  addMessage(msg) {
    setState(() {
      _messages.add(msg);
    });
  }
  // 여기를 이제 GET으로 가져와 미리 세팅하도록 수정하기

  final bool _showSpinner = false;
  final bool _showVisibleWidget = false;
  final bool _showErrorIcon = false;
  var socketFlag = false;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  dynamic socket;

  // Future<void> enterChatRoom() async {
  //   initialSocket();
  //   await Future.delayed(Duration(seconds: 2));
  //   print("hi");
  //   socket.emit('join', {'user': loginID, 'chatroom': chatroomID});
  //   print("bye");
  //
  //   // flag.then((val) {
  //   //   print('들어왔수다');
  //   // }).catchError((error) {
  //   //   print('error:$error');
  //   // });
  //   //
  //   // if (flag != null) {
  //   //   print("이젠 널이 아니에요");
  //   //   socket.emit('join', {'user': loginID, 'chatroom': chatroomID});
  //   // }
  //   // if (id != null) {
  //   //   print("들어왔어요");
  //   // } else {
  //   //   print("널이네요");
  //   // }
  // }

  // //되는거
  // Future<void> enterChatRoom() async {
  //   initialSocket();
  //   await Future.delayed(Duration(seconds: 2));
  //   print(socket.id);
  //   socket.emit('join', {'user': loginID, 'chatroom': chatroomID});
  // }

  // initializeSocket() {
  //   socket = io("http://10.0.2.2:3000/", <String, dynamic>{
  //     "transports": ["websocket"],
  //     "autoConnect": false,
  //   });
  //   socket.connect(); //connect the Socket.IO Client to the Server
  //
  //   //SOCKET EVENTS
  //   // --> listening for connection
  //   socket.on('connect', (data) {
  //     debugPrint(socket.connected);
  //   });
  //
  //   socket.on('join', (data) {
  //     debugPrint(data);
  //   });
  //
  //   //listen for incoming messages from the Server.
  //   socket.on('message', (data) {
  //     debugPrint(data); //
  //   });
  //
  //   //listens when the client is disconnected from the Server
  //   socket.on('disconnect', (data) {
  //     debugPrint('disconnect');
  //   });
  // }

  initializeSocket() {
    try {
      // socket = io('http://34.64.217.3:3000/', <String, dynamic>{
      //   'transports': ['websocket'],
      //   'autoConnect': false,
      // });
      socket = io('http://34.64.217.3:3000/', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket.connect();
      socket.on('connect', (data) {
        debugPrint('socket connected');
        // debugPrint(socket.connected);
        socket.emit('join', widget.chatroomID);
        setState(() {
          socketFlag = true;
        });
        debugPrint('연결완료');
      });

      socket.on('join', (data) {
        debugPrint('socket join');
        debugPrint(data);
      });

      socket.on('leave', (data) {
        debugPrint('socket leave');
      });

      socket.on('message', (data) {
        var message = ChatModel.fromJson(data);
        setStateIfMounted(() {
          _messages.add(message);
        });
      });
      socket.on('disconnect', (data) {
        debugPrint('socket disconnected');
        socket.disconnect();
      });
      // socket.onDisconnect((_) => debugPrint('disconnect'));
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getChatMessages(widget.chatroomID);
    for (var e in _samplemsg) {
      if (e.chatroomID == widget.chatroomID) {
        addMessage(e);
      }
    }

    super.initState();
    // enterChatRoom();
    initializeSocket();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            automaticallyImplyLeading: false,
            // backgroundColor: const Color(0xFF271160),
            backgroundColor: Colors.white,
            flexibleSpace: SafeArea(
              child: Container(
                padding: EdgeInsets.only(right: 16),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        socket.emit('leave', widget.chatroomID);
                        socket.emit('disconnect'); // 위에 socket.disconnect()와 연동
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
                        // Navigator.pushNamed(context, '/contacts');
                      },
                      child: CircleAvatar(
                        // 이미지자리
                        backgroundImage: NetworkImage(widget.friendImage),
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
                            widget.friendName,
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
          // appBar: AppBar(
          //     centerTitle: true,
          //     title: const Text('Chat Screen'),
          //     backgroundColor: const Color(0xFF271160)),
          body: SafeArea(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    // reverse: _messages.isEmpty ? false : true,
                    itemCount: 1,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 10, right: 10, bottom: 3),
                        child: Column(
                          mainAxisAlignment: _messages.isEmpty
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _messages.map((message) {
                                  print('gogo$message');
                                  return ChatBubble(
                                    date: message.sentAt,
                                    message: message.messagetext,
                                    // isMe: message.socketId ==
                                    //     socket
                                    //         .id, // message.userId == 로그인중인아이용
                                    isMe: message.senderID == widget.loginID,
                                  );
                                }).toList()),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 10,
                  top: 5),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onTap: () {},
                        decoration: InputDecoration.collapsed(
                            enabled: socketFlag ? true : false,
                            hintText:
                                socketFlag ? 'Write message...' : 'Loading...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none),
                        controller: _messageController,
                        scrollPadding: EdgeInsets.only(bottom: 40),
                      ),
                    ), // Send Button
                    SizedBox(
                      height: 43,
                      width: 42,
                      child: FloatingActionButton(
                        backgroundColor: const Color(0xFF271160),
                        onPressed: () async {
                          if (_messageController.text.trim().isNotEmpty) {
                            String message = _messageController.text.trim();

                            ChatModel nowSend = ChatModel(
                                // socketId: socket.id!,
                                chatroomID: widget.chatroomID,
                                messagetext: message,
                                senderID: widget.loginID,
                                receiverID: widget.friendID,
                                sentAt: DateTime.now()
                                    .toLocal()
                                    .toString()
                                    .substring(0, 16));

                            socket.emit('message', nowSend.toJson());
                            addMessage(nowSend);

                            // POST 요청을 보내 DB에 넣는 작업도 여기서 처리하게 수정하기

                            // 이후에 메세지 클리어하기
                            _messageController.clear();
                          }
                        },
                        mini: true,
                        child: Transform.rotate(
                            angle: 6, child: const Icon(Icons.send, size: 20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String date;

  ChatBubble({
    Key? key,
    required this.message,
    this.isMe = true,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            constraints: BoxConstraints(maxWidth: size.width * .5),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE3D8FF) : Colors.grey.shade200,
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topRight: Radius.circular(11),
                      topLeft: Radius.circular(11),
                      bottomRight: Radius.circular(0),
                      bottomLeft: Radius.circular(11),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(11),
                      topLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                      bottomLeft: Radius.circular(0),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  message,
                  textAlign: TextAlign.start,
                  softWrap: true,
                  style:
                      // const TextStyle(color: Color(0xFF2E1963), fontSize: 14),
                      const TextStyle(color: Color(0xFF000000), fontSize: 14),
                ),
                // 날짜 나옴
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 7),
                //     child: Text(
                //       date ?? '',
                //       textAlign: TextAlign.end,
                //       style: const TextStyle(
                //           color: Color(0xFF594097), fontSize: 9),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
