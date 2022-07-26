import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:nemo_flutter/screens/mypage/profile_page.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mypage/cardeditor.dart';
import '../../models/sharing/user.dart';
import '../sharing/punch.dart';
import 'package:dio/dio.dart';

// geolocator
import 'package:geolocator/geolocator.dart';

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
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CardEditor();
                }));
              }),
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
  // geolocator
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String lng = "", lat = "";
  late StreamSubscription<Position> positionStream;
// ---
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

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    lng = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(position.longitude);
      print(position.latitude);

      lng = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
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
                    // showSnackbar(
                    //     '와! 샌즈! 자동종료 확인 : ${endpointMap[id]!.endpointName}');
                    // showSnackbar('5초 타이머 자동 연결종료');

                  } else {
                    // showSnackbar('와! Sends! 실패했어요!');
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
                          // showSnackbar(
                          //     '와! 샌즈! 자동종료 확인 : ${endpointMap[id]!.endpointName}');
                        });
                      } else {
                        // showSnackbar('와! Sends! 실패했어요!');
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
        child: Container(
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
            'http://34.64.217.3:3000/api/friend?id_1=$id_1&id_2=$id_2&lat=$lat&lng=$lng');
        var request = http.MultipartRequest('GET', uri);

        final response = await request.send();
        if (response.statusCode == 200) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PunchPage(friendId: id_2)));
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
    getLocation();
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
  List friends = [];
  var myDataFromJson;
  Map myData = {};
  getAllCards(id) async {
    try {
      var dio = Dio();
      Response response = await dio.get('http://34.64.217.3:3000/api/card/$id');

      if (response.statusCode == 200) {
        myData = response.data;
        setState(() {
          myDataFromJson = User.fromJson(myData); // Instance User
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
    await getAllCards(nowId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    if (myDataFromJson != null) {
      return Container(
        // color: Colors.red,
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: ListView(
          // scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Container(
              // height: 500,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // add this
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    child: Image.network(
                      'http://34.64.217.3:3000/static/${myDataFromJson.image}',
                      width: 300,
                      height: 240,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${myDataFromJson.nickname}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 0)),
                            Container(
                              padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
                              decoration: BoxDecoration(
                                color: Color(0xff8338EC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '#${myDataFromJson.tag_1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 0)),
                            Container(
                              padding: EdgeInsets.fromLTRB(7, 1, 7, 1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  width: 1.5,
                                  color: Color(0xff8338EC),
                                ),
                              ),
                              child: Text(
                                '#${myDataFromJson.tag_2}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 0)),
                            Container(
                              padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
                              decoration: BoxDecoration(
                                color: Color(0xff8338EC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '#${myDataFromJson.tag_3}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${myDataFromJson.intro}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      );
    }
  }
}
