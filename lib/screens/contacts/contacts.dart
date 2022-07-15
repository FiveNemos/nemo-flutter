import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/contacts/user.dart';
import '../../tests/contacts/preferences.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  deleteFriend(target) {
    setState(() {
      Friends.remove(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: ListView.builder(
        itemCount: Friends.length,
        itemBuilder: (c, i) {
          return Container(
            margin: EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/mypage'),
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
                          width: 300,
                          height: 280,
                          fit: BoxFit.fill),
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
                        visualDensity: VisualDensity(vertical: 3),
                        title: Text(UserPreferences_db[Friends[i]].nickname,
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            UserPreferences_db[Friends[i]].introduction,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
              Navigator.pushNamed(context, '/contacts');
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
            height: 300,
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
