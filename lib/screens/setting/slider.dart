import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
// import '../sharing/nearby.dart';
// --
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../contacts/contacts.dart';
// --

class PhysicsCardDragDemo extends StatelessWidget {
  const PhysicsCardDragDemo({super.key});

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
  final String userName = Random().nextInt(10000).toString();
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
          {
            try {
              bool a = await Nearby().startAdvertising(
                userName,
                strategy,
                onConnectionInitiated: onConnectionInit,
                onConnectionResult: (id, status) {
                  if (status == Status.CONNECTED) {
                    endpointMap.forEach((key, value) async {
                      dynamic userInfo = await storage.read(key: 'login');
                      Map userMap = jsonDecode(userInfo);
                      String a = userMap['user_id'];
                      // String a = Random().nextInt(100).toString();

                      // showSnackbar(
                      //     'Sending $a to ${value.endpointName}, id: $key');
                      Nearby().sendBytesPayload(
                          key, Uint8List.fromList(a.codeUnits));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContactsPage()));
                    });
                  } else {
                    showSnackbar('Connection to $id failed');
                  }
                },
                onDisconnected: (id) {
                  showSnackbar(
                      'Disconnected: ${endpointMap[id]!.endpointName}, id $id');
                  setState(() {
                    endpointMap.remove(id);
                  });
                },
              );
            } catch (exception) {
              showSnackbar(exception);
            }
          }
        } else {
          // _runAnimation(Offset(0, 0), size);
          print('recieve');
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
                      // showSnackbar(status);
                    },
                    onDisconnected: (id) {
                      setState(() {
                        endpointMap.remove(id);
                      });
                      showSnackbar(
                          'Disconnected from: ${endpointMap[id]!.endpointName}, id $id');
                    },
                  );
                },
                onEndpointLost: (id) {
                  showSnackbar(
                      'Lost discovered Endpoint: ${endpointMap[id]!.endpointName}, id $id');
                },
              );
              showSnackbar('DISCOVERING: $a');
            } catch (e) {
              showSnackbar(e);
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
        // if (response.statusCode == 200) {

        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => ContactsPage()));
        Navigator.pushNamed(context, '/');
        // }
      }
    });
  }

  late AnimationController _controller;

  /// The alignment of the card as it is dragged or being animated.
  ///
  /// While the card is being dragged, this value is set to the values computed
  /// in the GestureDetector onPanUpdate callback. If the animation is running,
  /// this value is set to the value of the [_animation].
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

  // @override
  // Widget build(BuildContext context) {

  // }
}

// -----

class TookPage extends StatefulWidget {
  const TookPage({Key? key}) : super(key: key);

  @override
  _TookPageState createState() => _TookPageState();
}

class _TookPageState extends State<TookPage> {
  @override
  Widget build(BuildContext context) {
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
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // add this
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  child: Image.network(
                    'http://34.64.217.3:3000/static/gonigoni.gif',
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
                            '고니고니',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 0)),
                          Text(
                            '#태그1',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 0)),
                          Text(
                            '#태그2',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 0)),
                          Text(
                            '#태그3',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '캣홀릭 오타쿠 캣홀릭 오타쿠 캣홀릭 오타쿠',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(
          //   // decoration: BoxDecoration(color: Colors.pink),
          //   height: 100,
          // )
        ],
      ),
    );
  }
}
