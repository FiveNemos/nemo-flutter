import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/physics.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:nemo_flutter/screens/sharing/sharing_qr_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../providers/bottomBar.dart';
import '../mypage/cardeditor.dart';
import '../../models/sharing/user.dart';
import '../sharing/punch.dart';
import 'package:dio/dio.dart';
import 'package:flutter_switch/flutter_switch.dart';

// geolocator
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

class SharingPage extends StatefulWidget {
  const SharingPage({super.key});

  @override
  State<SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  bool isQRmode = false;
  int loginID = 0;
  static final storage = FlutterSecureStorage();
  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      loginID = int.parse(jsonDecode(userInfo)['user_id']);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _showDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            // title: new Text("TooK 가이드"),
            content: SingleChildScrollView(
              // height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                // alignment: Alignment.center,
                children: <Widget>[
                  Text('툭 사용법을 알려드릴게요!',
                      style: TextStyle(
                          fontFamily: 'Gamja',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    'assets/took_up.jpg',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('- 한 명은 위로 올려서 보내요!',
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Dohyun',
                          fontWeight: FontWeight.bold,
                          color: Colors.orange)),
                  SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    'assets/took_down.jpg',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('- 다른 한 명은 아래로 내려 받아요!',
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Dohyun',
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  SizedBox(
                    height: 20,
                  ),

                  Text('서로의 명함이 교환되면...',
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Dohyun',
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  // SizedBox(height: 30),
                  SizedBox(
                    width: 350.0,
                    height: 80.0,
                    child: Shimmer.fromColors(
                      baseColor: Colors.red,
                      highlightColor: Colors.yellow,
                      child: Text(
                        'TooK !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/bump_hand.gif',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  // SizedBox(
                  //   height: 200,
                  // ),
                ],
              ),
            ),
            // add text
            actions: <Widget>[
              ElevatedButton(
                child: Text('아~ 완벽히 이해했어요!',
                    style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontFamily: 'Dohyun')),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NeMo',
          style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CardEditor();
              }));
            }),

        actions: [
          buildSwitch2(),
        ],
        // bottomOpacity: 0.8,

        bottom: PreferredSize(
          preferredSize: Size(50, 50),
          child: Container(
            alignment: Alignment.center,
            constraints: BoxConstraints.expand(height: 50),
            // button
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)))),
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(8.0)),
              // color: Colors.orange,
              child: Text(
                '처음 사용한다면 클릭!',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Gamja',
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _showDialog();
              },
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: loginID > 0
            ? DraggableCard(
                isQRmode: isQRmode, loginID: loginID, child: TookPage())
            : TookPage(),
      ),
      bottomNavigationBar: context
          .read<BottomNavigationProvider>()
          .bottomNavigationBarClick(2, context),
    );
  }

  Widget buildSwitch2() => Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 15, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlutterSwitch(
              width: 50.0,
              height: 30.0,
              // toggleSize: 45.0,
              value: isQRmode,
              // borderRadius: 30.0,
              padding: 1.0,
              activeToggleColor: Color(0xFF6E40C9),
              inactiveToggleColor: Color(0xFF2F363D),
              activeSwitchBorder: Border.all(
                color: Color(0xFF3C1E70),
                width: 2.0,
              ),
              inactiveSwitchBorder: Border.all(
                // color: Color(0xFFD1D5DA),
                color: Color(0xFF3C1E70),
                width: 2.0,
              ),
              activeColor: Color(0xFF271052),
              inactiveColor: Color(0xFF271052),
              // inactiveColor: Colors.white,
              activeIcon: Icon(
                Icons.qr_code,
                color: Color(0xFFF8E3A1),
              ),
              inactiveIcon: Icon(
                Icons.near_me,
                color: Color(0xFFFFDF5D),
              ),
              onToggle: (val) {
                setState(() {
                  isQRmode = val;
                });
              },
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              alignment: Alignment.centerRight,
              child: Text(isQRmode ? 'QR' : 'NearBy',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );

  Widget buildSwitch() => Transform.scale(
        scale: 1.1,
        child: Switch.adaptive(
          // thumbColor: MaterialStateProperty.all(Colors.red),
          // trackColor: MaterialStateProperty.all(Colors.orange),
          value: isQRmode,
          onChanged: (value) => setState(() => isQRmode = value),
          activeColor: Colors.blueAccent,
          activeTrackColor: Colors.blue.withOpacity(0.4),
          inactiveThumbColor: Colors.orange,
          inactiveTrackColor: Colors.white,
        ),
      );
  //here
}

/// A draggable card that moves back to [Alignment.center] when it's
/// released.
class DraggableCard extends StatefulWidget {
  const DraggableCard(
      {required this.child,
      required this.loginID,
      required this.isQRmode,
      super.key});

  final Widget child;
  final bool isQRmode;
  final int loginID;

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
  String lng = '', lat = '';
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

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);

  void handleTimeout() async {
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    print('타임아웃! 다시 시도해주세요.');
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
  Widget build(BuildContext context) {
    void handleTimeout() async {
      await Nearby().stopAdvertising();
    }

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

          if (widget.isQRmode) {
            showSnackbar('상대방에게 QR코드를 보여주세요!');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => QRforTOOK(
                        isSender: true,
                        myId: widget.loginID,
                        latlng: [lat, lng])));
          } else {
            showSnackbar('명함 보내는 중...');
            try {
              scheduleTimeout(5 * 1000);
              bool a = await Nearby().startAdvertising(
                userName,
                strategy,
                onConnectionInitiated: onConnectionInit,
                onConnectionResult: (id, status) {
                  if (status == Status.CONNECTED) {
                    endpointMap.forEach((key, value) async {
                      dynamic userInfo = await storage.read(key: 'login');
                      String a = jsonDecode(userInfo)['user_id'];
                      // var storage = await SharedPreferences.getInstance();
                      // String a = storage.getInt('id').toString();

                      Nearby().sendBytesPayload(
                          key, Uint8List.fromList(a.codeUnits));
                      showSnackbar(
                          '연결이 종료되었습니다 : ${endpointMap[id]!.endpointName}');
                      await Nearby().stopAdvertising();
                      showSnackbar('advertising을 종료합니다.');
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
                  setState(() {
                    endpointMap.remove(id);
                  });
                  // showSnackbar(
                  //     'Disconnected: ${endpointMap[id]!.endpointName}, id $id');
                },
              );
              // showSnackbar('ADVERTISING: $a');
            } catch (exception) {
              // showSnackbar(exception);
            }
          }
        } else {
          // _runAnimation(Offset(0, 0), size);
          print('receive');
          if (widget.isQRmode) {
            showSnackbar('상대방의 QR코드를 찍어주세요!');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => QRforTOOK(
                        isSender: false,
                        myId: widget.loginID,
                        latlng: [lat, lng])));
          } else {
            showSnackbar('명함 받는중...');
            try {
              scheduleTimeout(5 * 1000);
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
                              '연결이 종료되었습니다 : ${endpointMap[id]!.endpointName}');
                          await Nearby().stopDiscovery();
                          showSnackbar('Discovery를 종료합니다.');
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
      duration: Duration(milliseconds: 3000),
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
        String friendId = String.fromCharCodes(payload.bytes!);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PunchPage(
                    friendId: int.parse(friendId), latlng: [lat, lng])));
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
        // // background effect
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/background.jpeg'),
        //     fit: BoxFit.cover,
        //   ),
        // ),

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
                    child: Image(
                      image: CachedNetworkImageProvider(
                          'https://storage.googleapis.com/nemo-bucket/${myDataFromJson.image}'),
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
