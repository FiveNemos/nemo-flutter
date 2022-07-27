import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // json decode 등등 관리
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nemo_flutter/screens/mypage/profile_page.dart';
import '../../models/contacts/user.dart';
// import '../../tests/contacts/preferences.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  var nowId;
  List friends = [];
  List friendsStash = [];
  Map friendsData = {};
  var _controller = TextEditingController();
  getAllCards(id) async {
    try {
      var dio = Dio();
      Map nowfriendsData = {};
      Response response =
          await dio.get('http://34.64.217.3:3000/api/card/all/$id');
      if (response.statusCode == 200) {
        final json = response.data;

        json['cards'].forEach((e) {
          var friendId = e['user_id'];
          nowfriendsData[friendId] = User(
            imagePath: e['image'],
            nickname: e['nickname'],
            introduction: e['intro'],
            tag: [
              '#${e['tag_1']}',
              '#${e['tag_2']}',
              '#${e['tag_3']}',
            ],
          );
        });

        setState(() {
          friends = List.from(json['friends'].reversed);
          friendsData = nowfriendsData;
          friendsStash = friends;
        });
        print('접속 성공!');
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      print("뭔가 에러가");
      return false;
    }
  }

  deleteFriend(target) {
    setState(() {
      friends.remove(target);
      friendsData.remove(target);
    });
    // 친구 삭제하는 POST 요청 추가필요
  }

  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      nowId = int.parse(jsonDecode(userInfo)['user_id']);
    });
    await getAllCards(nowId);
  }

  searchContacts(text) {
    // 순서 유지되는지 확인하기
    setState(() {
      friends = friendsStash
          .where((x) => friendsData[x].nickname.startsWith(text))
          .toList();
    });
  }

  resetContacts() {
    setState(() {
      friends = friendsStash;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Nemo',
            style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 5),
              child: TextField(
                controller: _controller,
                onChanged: (text) async {
                  if (text.isNotEmpty) {
                    searchContacts(text);
                  } else {
                    resetContacts();
                    // await getAllCards(nowId); // 그냥 original friends로 바꾸는 방법도..
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.black, //Color(0xff8338EC)
                          iconSize: 15,
                          onPressed: () {
                            _controller.clear();
                            resetContacts();
                          }),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(22, 8, 22, 10),
                  shrinkWrap: false,
                  physics: BouncingScrollPhysics(),
                  itemCount: friends.length,
                  itemBuilder: (c, i) {
                    return InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) =>
                                  ProfilePage(friendId: friends[i]))),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1.0,
                              offset:
                                  Offset(2, 4), // changes position of shadow
                            ),
                          ],
                        ),
                        // margin: EdgeInsets.all(5),
                        height: 180,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Slidable(
                            key: UniqueKey(),
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              // dismissible: DismissiblePane(onDismissed: () {
                              //   // Navigator.pushNamed(context, '/contacts2');
                              //   doNothing;
                              // }),
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DialogUI(
                                              target: friends[i],
                                              deleteFriend: deleteFriend);
                                        });
                                  },
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // 정글러버, Pintos 정복자의 컬럼위치(위, 중간, 아래)
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(color: Colors.black)),
                                  ),
                                  child: Image.network(
                                    'http://34.64.217.3:3000/static/${friendsData[friends[i]].imagePath}',
                                    width: 155,
                                    height: 180,
                                    // alignment: Alignment(-1, -0.7),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(8, 14, 0, 0),
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.end, // 태그만 오른쪽 배치하고 싶다면
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // 사진 옆 박스 row 시작점
                                      children: [
                                        Text(
                                          friendsData[friends[i]].nickname,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        ),
                                        Text(
                                          friendsData[friends[i]].introduction,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        ),
                                        Wrap(
                                          direction: Axis.vertical,
                                          spacing:
                                              5, // gap between adjacent chips
                                          runSpacing: 4.0,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  8, 2, 8, 2),
                                              decoration: BoxDecoration(
                                                color: Color(0xff8338EC),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                friendsData[friends[i]].tag[0],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  7, 2, 7, 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  width: 1.5,
                                                  color: Color(0xff8338EC),
                                                ),
                                              ),
                                              child: Text(
                                                friendsData[friends[i]].tag[1],
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              // color: Colors.white,
                                              padding: EdgeInsets.fromLTRB(
                                                  8, 3, 8, 3),
                                              decoration: BoxDecoration(
                                                color: Color(0xff8338EC),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                friendsData[friends[i]].tag[2],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, i) => SizedBox(height: 10)),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts),
              label: '연락처',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.share),
              label: '공유',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: '메시지',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '마이페이지',
            ),
          ],
          currentIndex: 0,
          onTap: (int index) {
            switch (index) {
              case 0:
                // Navigator.pushNamed(context, '/contacts');
                break;
              case 1:
                Navigator.pushNamed(context, '/sharing');
                break;
              case 2:
                Navigator.pushNamed(context, '/map');
                break;
              case 3:
                Navigator.pushNamed(context, '/message');
                break;
              case 4:
                Navigator.pushNamed(context, '/mypage');
                break;
            }
          },
        ),
      ),
    );
  }
}

void doNothing(BuildContext context) {}

class DialogUI extends StatelessWidget {
  DialogUI({Key? key, this.target, this.deleteFriend}) : super(key: key);
  var target;
  var deleteFriend;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        alignment: Alignment.center,
        child: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('정말 삭제하시겠습니까?'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        deleteFriend(target);
                        Navigator.pop(context);
                      },
                      child: Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('No'),
                    )
                  ],
                )
              ],
            )));
  }
}
