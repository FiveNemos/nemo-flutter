import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class NearbyConnection extends StatefulWidget {
  @override
  _MyBodyState createState() => _MyBodyState();
}

class _MyBodyState extends State<NearbyConnection> {
  final String userName = Random().nextInt(10000).toString();
  final Strategy strategy = Strategy.P2P_POINT_TO_POINT;
  Map<String, ConnectionInfo> endpointMap = {};
  static final storage = FlutterSecureStorage();

  String? tempFileUri; //reference to the file currently being transferred
  Map<int, String> map = {}; //store filename mapped to corresponding payloadId
  checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      //add more permission to request here.
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    checkPermissions();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Text('User Name: $userName'),
            Wrap(
              children: <Widget>[
                ElevatedButton(
                  child: Text('Send Namecard'),
                  onPressed: () async {
                    endpointMap.forEach((key, value) async {
                      dynamic userInfo = await storage.read(key: 'login');
                      Map userMap = jsonDecode(userInfo);
                      String a = userMap['user_id'];

                      // String a = Random().nextInt(100).toString();

                      showSnackbar(
                          'Sending $a to ${value.endpointName}, id: $key');
                      Nearby().sendBytesPayload(
                          key, Uint8List.fromList(a.codeUnits));
                    });
                  },
                ),
                ElevatedButton(
                  child: Text('Start Advertising'),
                  onPressed: () async {
                    try {
                      bool a = await Nearby().startAdvertising(
                        userName,
                        strategy,
                        onConnectionInitiated: onConnectionInit,
                        onConnectionResult: (id, status) {
                          if (status == Status.CONNECTED) {
                            endpointMap.forEach((key, value) {
                              String a = Random().nextInt(100).toString();

                              showSnackbar(
                                  'Sending $a to ${value.endpointName}, id: $key');
                              Nearby().sendBytesPayload(
                                  key, Uint8List.fromList(a.codeUnits));
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
                      // showSnackbar("ADVERTISING: " + a.toString());
                    } catch (exception) {
                      showSnackbar(exception);
                    }
                  },
                ),
                ElevatedButton(
                  child: Text('Stop Advertising'),
                  onPressed: () async {
                    await Nearby().stopAdvertising();
                  },
                ),
              ],
            ),
            Wrap(
              children: <Widget>[
                ElevatedButton(
                  child: Text('Start Discovery'),
                  onPressed: () async {
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
                              showSnackbar(status);
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
                  },
                ),
                ElevatedButton(
                  child: Text('Stop Discovery'),
                  onPressed: () async {
                    await Nearby().stopDiscovery();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  startDiscovery() async {
    try {
      bool a = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          // show sheet automatically to request connection
          showModalBottomSheet(
            context: context,
            builder: (builder) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Text('id: $id'),
                    Text('Name: $name'),
                    Text('ServiceId: $serviceId'),
                    ElevatedButton(
                      child: Text('Request Connection'),
                      onPressed: () {
                        Navigator.pop(context);
                        Nearby().requestConnection(
                          userName,
                          id,
                          onConnectionInitiated: (id, info) {
                            onConnectionInit(id, info);
                          },
                          onConnectionResult: (id, status) {
                            showSnackbar(status);
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
                    ),
                  ],
                ),
              );
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

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  void onConnectionInit(String id, ConnectionInfo info) {
    setState(() {
      endpointMap[id] = info;
    });
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endid, payload) async {
        if (payload.type == PayloadType.BYTES) {
          String b = 'https://swjungle.net';

          final url = Uri.parse(b);

          if (await canLaunchUrl(url)) {
            launchUrl(url);
          } else {
            print('Could not launch $url');
          }

          String str = String.fromCharCodes(payload.bytes!);

          if (str.contains(':')) {
            int payloadId = int.parse(str.split(':')[0]);
            String fileName = (str.split(':')[1]);
          }
        }
      },
    );
  }
}
