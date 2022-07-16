import '../../models/message/chat_message_model.dart';

Map messages_db = {
  "Sanori": [
    ChatMessage(messageContent: "안녕하세요", messageType: "receiver"),
    ChatMessage(messageContent: "잘하고 계신가요 ㅎㅎ ", messageType: "receiver"),
    ChatMessage(
        messageContent: "앗 코치님! 플러터 하고 있어요. 금방 하겠죠..? ", messageType: "sender"),
    ChatMessage(messageContent: "예... 뭐 그럴수도 있겠다", messageType: "receiver"),
    ChatMessage(messageContent: "감... 감사합니다^^", messageType: "sender"),
  ],
  "Opjoobe": [
    ChatMessage(messageContent: "안녕하세요 주형님", messageType: "sender"),
    ChatMessage(
        messageContent: "앗 리더님! 친히 연락을 다 주시다니요", messageType: "receiver"),
    ChatMessage(messageContent: "농구 한판 하실래요 ?", messageType: "receiver"),
  ],
  "Jocy": [
    ChatMessage(messageContent: "안녕하세요 현욱님", messageType: "sender"),
    ChatMessage(messageContent: "네 안녕하세요~", messageType: "receiver"),
    ChatMessage(messageContent: "커피 한잔 하실래요 ?", messageType: "receiver"),
  ],
  "Jessy": [
    ChatMessage(messageContent: "안녕하세요 현주님", messageType: "sender"),
    ChatMessage(messageContent: "일어나셨나요 ?", messageType: "sender"),
    ChatMessage(messageContent: "현주님.....?", messageType: "sender"),
    ChatMessage(messageContent: "님..?", messageType: "sender"),
  ],
  "정글러버": [
    ChatMessage(
        messageContent: "안녕하세요! \n 다음 캠핑 모임 나오시나요?", messageType: "sender"),
    ChatMessage(
        messageContent: "앗!! \n 제가 이사가서 이제 모임 참석이 어려울거 같아요 😢 ",
        messageType: "receiver"),
    ChatMessage(messageContent: "그동안 같이 캠핑해서 즐거웠어요!", messageType: "receiver"),
    ChatMessage(messageContent: "👋👋👋👋👋👋👋", messageType: "sender"),
  ],
  "배그러버": [
    ChatMessage(messageContent: "안녕하세요! \n 피시방 가실까요?", messageType: "sender"),
    ChatMessage(
        messageContent: "앗!! \n 제가 이사가서 이제 모임 참석이 어려울거 같아요 😢 ",
        messageType: "receiver"),
    ChatMessage(messageContent: "그동안 같이 배그해서 즐거웠어요!", messageType: "receiver"),
    ChatMessage(messageContent: "앗 이런 ㅠㅠ", messageType: "sender"),
  ],
  "Chani": [
    ChatMessage(messageContent: "안녕하세요 찬익님", messageType: "sender"),
    ChatMessage(messageContent: "블루베리 가자구요?", messageType: "receiver"),
    ChatMessage(messageContent: "좋~죠~", messageType: "sender"),
  ],
  "Krafton": [
    ChatMessage(
        messageContent: "안녕하세요 의장님:) 저희 발표 혹시..", messageType: "sender"),
    ChatMessage(messageContent: "내가 말했지", messageType: "receiver"),
    ChatMessage(
        messageContent: "니 인생은 너꺼야!!! 운영진 신경쓰지마!!", messageType: "receiver"),
    ChatMessage(messageContent: "알겠어?!!", messageType: "receiver"),
  ],
  "고니고니": [
    ChatMessage(messageContent: "의장님께 채팅보내보기", messageType: "sender"),
    ChatMessage(messageContent: "계란 2주내로 먹기", messageType: "sender"),
  ],
  "Sparta": [
    ChatMessage(messageContent: "안녕하세요 성곤님", messageType: "receiver"),
    ChatMessage(messageContent: "대표님 안녕하세요!", messageType: "sender"),
    ChatMessage(messageContent: "디스 이즈 스파르타 !!!", messageType: "receiver"),
  ],
};
