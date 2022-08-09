class ChatRooms {
  var chatroomID;
  int friendID;
  String friendName;
  String intro;
  String friendImage;
  DateTime lastMsgTime;
  String lastMsgText;
  int notReadCnt;
  // bool isMessageRead;
  ChatRooms(
      {required this.chatroomID,
      required this.friendID,
      required this.friendName,
      required this.intro,
      required this.friendImage,
      required this.lastMsgTime,
      required this.lastMsgText,
      required this.notReadCnt});
}
