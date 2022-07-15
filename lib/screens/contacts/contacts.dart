import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nemo_flutter/screens/mypage/profile_page.dart';
import '../../models/contacts/user.dart';
import '../../tests/contacts/preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  static final storage = FlutterSecureStorage();
  String? userInfo = '';

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
      Navigator.pushNamed(context, '/');
    }
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
            icon: new Icon(Icons.logout),
            tooltip: 'logout',
            onPressed: () {
              logout();
            },
          ),
        ],
      ),
      body: ListView.separated(
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          itemCount: Friends.length,
          itemBuilder: (c, i) {
            return Container(
              // color: Color(0xff8338EC),
              // padding: EdgeInsets.fromLTRB(15, 20, 20, 15),
              // margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Card(
                // margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: InkWell(
                  // onTap: () => Navigator.pushNamed(context, '/mypage'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => ProfilePage(nickname: Friends[i]))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // add this
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                        child: Image.network(
                          UserPreferences_db[Friends[i]].imagePath,
                          height: 220,
                          alignment: Alignment(0, -0.7),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Slidable(
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
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity(vertical: 1),
                          title: Text(UserPreferences_db[Friends[i]].nickname,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              UserPreferences_db[Friends[i]].introduction,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, i) => SizedBox(height: 10)),
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
