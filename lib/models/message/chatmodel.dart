import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  ChatModel({
    // required this.socketId,
    required this.chatroomID,
    required this.senderID,
    required this.receiverID,
    required this.sentAt,
    required this.messagetext,
    required this.isread,
  });

  // String socketId;
  var chatroomID;
  int senderID; // 수정하기 int
  int receiverID;
  String sentAt;
  String messagetext;
  bool isread;

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        // socketId: json["socketId"],
        chatroomID: json['chatroomID'],
        senderID: json['senderID'],
        receiverID: json['receiverID'],
        sentAt: json['sentAt'],
        messagetext: json['messagetext'],
        isread: json['isread'],
      );

  Map<String, dynamic> toJson() => {
        // "socketId": socketId, // socketId 혹시모르니
        'chatroomID': chatroomID,
        'senderID': senderID, // sender userId
        'receiverID': receiverID,
        'sentAt': sentAt, // 언제보냈는가
        'messagetext': messagetext, // 메세지 내용
        'isread': isread,
      };
}
