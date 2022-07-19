import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert'; // json decode 등등 관리
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nemo_flutter/screens/mypage/profile_page.dart';
import '../../tests/contacts/preferences.dart';
import '../../models/contacts/user.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';

  deleteFriend(target) {
    setState(() {
      Friends.remove(target);
    });
  }

  logout() async {
    await storage.delete(key: 'login');
    Navigator.pushNamed(context, '/');
  }

  checkUserState() async {
    userInfo = await storage.read(key: 'login');
    if (userInfo == null) {
      print('로그아웃 합니다');
      Navigator.pushNamed(context, '/');
    } else {
      print('로그인 중');
    }
  }

  checkUser() async {
    userInfo = await storage.read(key: 'login');
    Map userMap = jsonDecode(userInfo);
    print('userMap');
    print(userMap.runtimeType);
    print('accountName 값');
    print(userMap['accountName']);
    print('user_id 값');
    print(userMap['user_id']);
  }

  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'logout',
            onPressed: () {
              logout();
            },
          ),
          IconButton(
            icon: Icon(Icons.star),
            tooltip: 'star',
            onPressed: () {
              checkUser();
            },
          ),
        ],
      ),
      body: ListView.separated(
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          itemCount: Friends.length,
          itemBuilder: (c, i) {
            return InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => ProfilePage(nickname: Friends[i]))),
              child: Container(
                // color: Colors.black,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10)),
                // margin: EdgeInsets.all(5),
                height: 150,
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
                                      target: Friends[i],
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
                                right: BorderSide(
                              color: Colors.black,
                            )),
                          ),
                          child: Image.network(
                            UserPreferences_db[Friends[i]].imagePath,
                            height: 150,
                            width: 150,
                            // alignment: Alignment(-1, -0.7),
                            // fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // 사진 옆 박스 row 시작점
                              children: [
                                Text(UserPreferences_db[Friends[i]].nickname,
                                    style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    UserPreferences_db[Friends[i]].introduction,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600)),
                                Row(
                                  // for TAGS
                                  // mainAxisAlignment: MainAxisAlignment.end, // 태그만 오른쪽 배치하고 싶다면
                                  children: [
                                    Text(
                                      UserPreferences_db[Friends[i]].tag[0],
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      UserPreferences_db[Friends[i]].tag[1],
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      UserPreferences_db[Friends[i]].tag[2],
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
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
          separatorBuilder: (context, i) => SizedBox(height: 20)),
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
              Navigator.pushNamed(context, '/message');
              break;
            case 3:
              Navigator.pushNamed(context, '/mypage');
              break;
          }
        },
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
                Text("정말 삭제하시겠습니까?"),
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
