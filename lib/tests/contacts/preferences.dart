import '../../models/contacts/user.dart';

Map UserPreferences_db = {
  '정글러버': User(
    imagePath: 'http://34.64.217.3:3000/static/junglelover.gif',
    nickname: '정글러버',
    introduction: 'Pintos 정복자 😎',
    tag: ['#코딩잘하나요', '#캠핑', '#베이킹'],
  ),
  '배그러버': User(
    imagePath: 'http://34.64.217.3:3000/static/bglover.png',
    nickname: '배그러버',
    introduction: '포친키 탄약도둑 😝',
    tag: [
      '#배그',
      '#애니',
      '#커피',
      '#코딩',
    ],
  ),
  'Opjoobe': User(
    imagePath: 'http://34.64.217.3:3000/static/opjoobe.gif',
    nickname: 'Opjoobe',
    introduction: 'Ball is Life',
    tag: ['#농구꽤하지', '#독서좋아요', '#다리우스', '#코딩천잽니다'],
  ),
};
List Friends = ['정글러버', '배그러버', 'Opjoobe'];
