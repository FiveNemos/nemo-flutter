import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  ChatModel({
    // required this.socketId,
    required this.chatroomID,
    required this.senderID,
    required this.sentAt,
    required this.message,
  });

  // String socketId;
  var chatroomID;
  int senderID; // 수정하기 int
  String sentAt;
  String message;

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        // socketId: json["socketId"],
        chatroomID: json['chatroomID'],
        senderID: json['senderID'],
        sentAt: json['sentAt'],
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        // "socketId": socketId, // socketId 혹시모르니
        'chatroomID': chatroomID,
        'senderID': senderID, // sender userId
        'sentAt': sentAt, // 언제보냈는가
        'message': message, // 메세지 내용
      };
}
