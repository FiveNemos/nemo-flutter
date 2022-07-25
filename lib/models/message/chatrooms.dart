class ChatRooms {
  var chatroomID;
  int friendID;
  String friendName;
  String intro;
  String friendImage;
  String lastMsgTime;
  // bool isMessageRead;
  ChatRooms({
    required this.chatroomID,
    required this.friendID,
    required this.friendName,
    required this.intro,
    required this.friendImage,
    required this.lastMsgTime,
  });
}
