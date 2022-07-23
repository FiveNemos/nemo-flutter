import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
// import '../sharing/nearby.dart';
// --
import 'dart:math';
import 'dart:typed_data';

import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nemo_flutter/screens/mypage/profile_page.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../contacts/contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';
import '../../models/contacts/user.dart';

// --

class SharingPage extends StatelessWidget {
  const SharingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOOK 페이지'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/namecard');
            },
          ),
        ],
      ),
      body: const DraggableCard(
        child: TookPage(),
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
        currentIndex: 1,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/contacts');
              break;
            case 1:
              Navigator.pushNamed(context, '/setting');
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

/// A draggable card that moves back to [Alignment.center] when it's
/// released.
class DraggableCard extends StatefulWidget {
  const DraggableCard({required this.child, super.key});

  final Widget child;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  final String userName = Random().nextInt(100).toString();
  final Strategy strategy = Strategy.P2P_POINT_TO_POINT;
  Map<String, ConnectionInfo> endpointMap = {};
  static final storage = FlutterSecureStorage();

  String? tempFileUri; //reference to the file currently being transferred
  Map<int, String> map = {}; //store filename mapped to corresponding payloadId
  checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      // Permission.bluetooth,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.storage,
      //add more permission to request here.
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    checkPermissions();
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
        });
      },
      onPanEnd: (details) async {
        print(details.velocity.pixelsPerSecond.dy);
        if (details.velocity.pixelsPerSecond.dy < 0) {
          print('send');
          showSnackbar('명함 보내는 중...');

          {
            try {
              bool a = await Nearby().startAdvertising(
                userName,
                strategy,
                onConnectionInitiated: onConnectionInit,
                onConnectionResult: (id, status) {
                  if (status == Status.CONNECTED) {
                    endpointMap.forEach((key, value) async {
                      // dynamic userInfo =
                      //     await storage.read(key: 'login');
                      // Map userMap = jsonDecode(userInfo);
                      // String a = userMap['user_id'];
                      var storage = await SharedPreferences.getInstance();
                      String a = storage.getInt('id').toString();

                      Nearby().sendBytesPayload(
                          key, Uint8List.fromList(a.codeUnits));
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => SharingPage()));
                    });

                    // OnDisconnected:
                    // (id) {
                    //   setState(() {
                    //     endpointMap.remove(id);
                    //   });
                    //   showSnackbar(
                    //       '자동종료 확인 : ${endpointMap[id]!.endpointName}');
                    // };
                    setState(() {
                      endpointMap.remove(id);
                    });
                    showSnackbar(
                        '와! 샌즈! 자동종료 확인 : ${endpointMap[id]!.endpointName}');
                    // showSnackbar('5초 타이머 자동 연결종료');

                  } else {
                    showSnackbar('와! Sends! 실패했어요!');
                  }

                  // showSnackbar(
                  //     'Connected: ${endpointMap[id]!.endpointName}, id $id');
                },
                onDisconnected: (id) {
                  // showSnackbar(
                  //     'Disconnected: ${endpointMap[id]!.endpointName}, id $id');
                  setState(() {
                    endpointMap.remove(id);
                  });
                },
              );
              // showSnackbar('ADVERTISING: $a');
            } catch (exception) {
              // showSnackbar(exception);
            }
          }
        } else {
          // _runAnimation(Offset(0, 0), size);
          print('recieve');
          showSnackbar('명함 받는중...');

          {
            try {
              bool a = await Nearby().startDiscovery(
                userName,
                strategy,
                onEndpointFound: (id, name, serviceId) {
                  // show sheet automatically to request connection
                  // Navigator.pop(context);
                  Nearby().requestConnection(
                    userName,
                    id,
                    onConnectionInitiated: (id, info) {
                      onConnectionInit(id, info);
                    },
                    onConnectionResult: (id, status) {
                      if (status == Status.CONNECTED) {
                        endpointMap.forEach((key, value) async {
                          dynamic userInfo = await storage.read(key: 'login');
                          Map userMap = jsonDecode(userInfo);
                          String a = userMap['user_id'];

                          Nearby().sendBytesPayload(
                              key, Uint8List.fromList(a.codeUnits));
                          setState(() {
                            endpointMap.remove(id);
                          });
                          showSnackbar(
                              '와! 샌즈! 자동종료 확인 : ${endpointMap[id]!.endpointName}');
                        });
                      } else {
                        showSnackbar('와! Sends! 실패했어요!');
                      }
                    },
                    onDisconnected: (id) {
                      setState(() {
                        endpointMap.remove(id);
                      });
                      // showSnackbar(
                      //     'Disconnected from: ${endpointMap[id]!.endpointName}, id $id');
                    },
                  );
                },
                onEndpointLost: (id) {
                  // showSnackbar(
                  //     'Lost discovered Endpoint: ${endpointMap[id]!.endpointName}, id $id');
                },
              );
              // showSnackbar('DISCOVERING: $a');
            } catch (e) {
              // showSnackbar(e);
            }
          }
        }

        _runAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
        alignment: _dragAlignment,
        child: Card(
          child: widget.child,
        ),
      ),
    );
  }
  // }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  // void onConnectionInit(String id, ConnectionInfo info) {
  //   setState(() {
  //     endpointMap[id] = info;
  //   });
  //   Nearby().acceptConnection(id, onPayLoadRecieved: (endid, payload) async {
  //     if (payload.type == PayloadType.BYTES) {
  //       dynamic userInfo = await storage.read(key: 'login');
  //       Map userMap = jsonDecode(userInfo);
  //       String id_1 = userMap['user_id'];
  //       String id_2 = String.fromCharCodes(payload.bytes!);

  //       var uri = Uri.parse(
  //           'http://34.64.217.3:3000/api/friend?id_1=$id_1&id_2=$id_2');
  //       var request = http.MultipartRequest('GET', uri);

  //       final response = await request.send();
  //       if (response.statusCode == 200) {
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => ProfilePage(friendId: id_2)));
  //       }
  //     }
  //   });
  // }
  void onConnectionInit(String id, ConnectionInfo info) {
    setState(() {
      endpointMap[id] = info;
    });
    Nearby().acceptConnection(id, onPayLoadRecieved: (endid, payload) async {
      if (payload.type == PayloadType.BYTES) {
        dynamic userInfo = await storage.read(key: 'login');
        Map userMap = jsonDecode(userInfo);
        String id_1 = userMap['user_id'];
        String id_2 = String.fromCharCodes(payload.bytes!);

        var uri = Uri.parse(
            'http://34.64.217.3:3000/api/friend?id_1=$id_1&id_2=$id_2');
        var request = http.MultipartRequest('GET', uri);

        final response = await request.send();
        if (response.statusCode == 200) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(friendId: id_2)));
        }
      }
    });
  }

  late AnimationController _controller;

  Alignment _dragAlignment = Alignment.center;

  late Animation<Alignment> _animation;

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 10,
      stiffness: 1,
      damping: 5,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// -----

class TookPage extends StatefulWidget {
  const TookPage({Key? key}) : super(key: key);

  @override
  _TookPageState createState() => _TookPageState();
}

class _TookPageState extends State<TookPage> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  var nowId;
  // List friends = [];
  Map userData = {};
  getMyCards(id) async {
    try {
      var dio = Dio();
      Response response =
          await dio.get('http://34.64.217.3:3000/api/card/all/$id');

      if (response.statusCode == 200) {
        print(id);

        final json = response.data;
        json.forEach((e) {
          var friendId = e['user_id'];
          setState(() {
            userData[friendId] = User(
              imagePath: e['img_url'],
              nickname: e['nickname'],
              introduction: e['intro'],
              tag: [
                '#${e['tag_1']}',
                '#${e['tag_2']}',
                '#${e['tag_3']}',
              ],
            );
            // friends.add(friendId);
          });
        });
        print('접속 성공!');
        return true;
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      nowId = jsonDecode(userInfo)['user_id'];
    });
    await getMyCards(nowId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      padding: EdgeInsets.fromLTRB(22, 8, 22, 10),
      itemCount: 1,
      itemBuilder: (c, i) {
        return InkWell(
          // onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (c) => ProfilePage(friendId: friends[i]))),
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
                  offset: Offset(2, 4), // changes position of shadow
                ),
              ],
            ),
            // margin: EdgeInsets.all(5),
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment
                    .start, // 정글러버, Pintos 정복자의 컬럼위치(위, 중간, 아래)
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.black)),
                    ),
                    child: Image.network(
                      'http://34.64.217.3:3000/static/1657692059857-space.jpg',
                      width: 155,
                      height: 180,
                      // alignment: Alignment(-1, -0.7),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(8, 14, 5, 0),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.end, // 태그만 오른쪽 배치하고 싶다면
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // 사진 옆 박스 row 시작점
                        children: [
                          Text(
                            nowId.nickname,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          ),
                          Text(
                            nowId.introduction,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          ),
                          Wrap(
                            direction: Axis.vertical,
                            spacing: 5, // gap between adjacent chips
                            runSpacing: 4.0,
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                                decoration: BoxDecoration(
                                  color: Color(0xff8338EC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  nowId.tag[0],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1.5,
                                    color: Color(0xff8338EC),
                                  ),
                                ),
                                child: Text(
                                  nowId.tag[1],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                // color: Colors.white,
                                padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                                decoration: BoxDecoration(
                                  color: Color(0xff8338EC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  nowId.tag[2],
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
        );
      },
    ));
  }
}
