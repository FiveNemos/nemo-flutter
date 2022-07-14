import '../../models/contacts/contacts_user.dart';

Map UserPreferences_db = {
  '정글러버': User(
    imagePath: 'http://34.64.217.3:3000/static/junglelover.gif',
    nickname: '정글러버',
    introduction: 'Pintos 정복자 😎',
  ),
  '배그러버': User(
    imagePath: 'http://34.64.217.3:3000/static/bglover.png',
    nickname: '배그러버',
    introduction: '포친키 탄약도둑 😝',
  ),
  'Opjoobe': User(
    imagePath: 'http://34.64.217.3:3000/static/opjoobe.gif',
    nickname: 'Opjoobe',
    introduction: 'Ball is Life',
  ),
};
List Friends = ['정글러버', '배그러버', 'Opjoobe'];
