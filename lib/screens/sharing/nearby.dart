import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
// import 'package:permission_handler/permission_handler.dart';

import 'package:url_launcher/url_launcher.dart';

class NearbyConnection extends StatefulWidget {
  @override
  _MyBodyState createState() => _MyBodyState();
}

class _MyBodyState extends State<NearbyConnection> {
  final String userName = Random().nextInt(10000).toString();
  final Strategy strategy = Strategy.P2P_POINT_TO_POINT;
  Map<String, ConnectionInfo> endpointMap = Map();

  String? tempFileUri; //reference to the file currently being transferred
  Map<int, String> map =
      Map(); //store filename mapped to corresponding payloadId

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Text("User Name: " + userName),
            Wrap(
              children: <Widget>[
                ElevatedButton(
                  child: Text("Send Namecard"),
                  onPressed: () async {
                    endpointMap.forEach((key, value) {
                      String a = Random().nextInt(100).toString();

                      // showSnackbar(
                      //     "Sending $a to ${value.endpointName}, id: $key");
                      Nearby().sendBytesPayload(
                          key, Uint8List.fromList(a.codeUnits));
                    });
                  },
                ),
                ElevatedButton(
                  child: Text("Start Advertising"),
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
                                  "Sending $a to ${value.endpointName}, id: $key");
                              Nearby().sendBytesPayload(
                                  key, Uint8List.fromList(a.codeUnits));
                            });
                          } else {
                            showSnackbar("Connection to $id failed");
                          }
                        },
                        onDisconnected: (id) {
                          showSnackbar(
                              "Disconnected: ${endpointMap[id]!.endpointName}, id $id");
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
                  child: Text("Stop Advertising"),
                  onPressed: () async {
                    await Nearby().stopAdvertising();
                  },
                ),
              ],
            ),
            Wrap(
              children: <Widget>[
                ElevatedButton(
                  child: Text("Start Discovery"),
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
                                  "Disconnected from: ${endpointMap[id]!.endpointName}, id $id");
                            },
                          );
                        },
                        onEndpointLost: (id) {
                          showSnackbar(
                              "Lost discovered Endpoint: ${endpointMap[id]!.endpointName}, id $id");
                        },
                      );
                      showSnackbar("DISCOVERING: " + a.toString());
                    } catch (e) {
                      showSnackbar(e);
                    }
                  },
                ),
                ElevatedButton(
                  child: Text("Stop Discovery"),
                  onPressed: () async {
                    await Nearby().stopDiscovery();
                  },
                ),
              ],
            ),
            Text("Number of connected devices: ${endpointMap.length}"),
            ElevatedButton(
              child: Text("Stop All Endpoints"),
              onPressed: () async {
                await Nearby().stopAllEndpoints();
                setState(() {
                  endpointMap.clear();
                });
              },
            ),
            Divider(),
            Text(
              "Permissions",
            ),
            Wrap(
              children: <Widget>[
                ElevatedButton(
                  child: Text("askLocationPermission"),
                  onPressed: () async {
                    if (await Nearby().askLocationPermission()) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Location Permission granted :)")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("Location permissions not granted :(")));
                    }
                  },
                ),
                ElevatedButton(
                  child: Text("askExternalStoragePermission"),
                  onPressed: () {
                    Nearby().askExternalStoragePermission();
                  },
                ),
                ElevatedButton(
                  child: Text("askBluetoothPermission (Android 12+)"),
                  onPressed: () {
                    Nearby().askBluetoothPermission();
                  },
                ),
              ],
            ),
            // Divider(),
            // Text("Location Enabled"),
            // Wrap(
            //   children: <Widget>[
            //     ElevatedButton(
            //       child: Text("enableLocationServices"),
            //       onPressed: () async {
            //         if (await Nearby().enableLocationServices()) {
            //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //               content: Text("Location Service Enabled :)")));
            //         } else {
            //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //               content:
            //                   Text("Enabling Location Service Failed :(")));
            //         }
            //       },
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
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
          String b = "https://swjungle.net";

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
