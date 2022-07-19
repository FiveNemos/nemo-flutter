import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipe/swipe.dart';
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
  final Strategy strategy = Strategy.P2P_STAR;
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
    FlutterNfcReader.read().then((response) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                  '${response.id}\n${response.content}\n${response.error}'),
            );
          });
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Swipe(
              child: SizedBox(
                width: 500,
                height: 300,
                child: Column(
                  children: [
                    ElevatedButton(
                      child: Text('Get my id'),
                      onPressed: () async {
                        dynamic userInfo = await storage.read(key: 'login');
                        // Map userMap = jsonDecode(userInfo);
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                  child: Text(userInfo.split(' ')[1]));
                            });
                      },
                    ),
                    Text('Swipe Up to Send!!'),
                    ElevatedButton(
                      child: Text('Stop Advertising'),
                      onPressed: () async {
                        await Nearby().stopAdvertising();
                      },
                    ),
                    ElevatedButton(
                        child: Text('Start Discovery'),
                        onPressed: () {
                          startDiscovery();
                        }),
                    ElevatedButton(
                      child: Text('Stop Discovery'),
                      onPressed: () async {
                        await Nearby().stopDiscovery();
                      },
                    ),
                    ElevatedButton(
                      child: Text('Stop All Endpoints'),
                      onPressed: () async {
                        await Nearby().stopAllEndpoints();
                        setState(() {
                          endpointMap.clear();
                        });
                      },
                    ),
                    Text('Number of connected devices: ${endpointMap.length}'),
                  ],
                ),
              ),
              onSwipeUp: () async {
                try {
                  bool a = await Nearby().startAdvertising(
                    userName,
                    strategy,
                    onConnectionInitiated: onConnectionInit,
                    onConnectionResult: (id, status) {
                      showSnackbar(status);
                    },
                    onDisconnected: (id) {
                      showSnackbar(
                          'Disconnected: ${endpointMap[id]!.endpointName}, id $id');
                      setState(() {
                        endpointMap.remove(id);
                      });
                    },
                  );
                  showSnackbar('ADVERTISING: $a');
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Let\'s send!'),
                          content: Text('명함을 보내시겠습니까?'),
                          actions: [
                            TextButton(
                              // textColor: Colors.black,
                              onPressed: () async {
                                endpointMap.forEach((key, value) {
                                  String a = Random().nextInt(100).toString();
                                  showSnackbar(
                                      'Sending $a to ${value.endpointName}, id: $key');
                                  Nearby().sendBytesPayload(
                                      key, Uint8List.fromList(a.codeUnits));
                                });
                                Navigator.pop(context);
                              },
                              child: Text('확인'),
                            ),
                          ],
                        );
                      });
                } catch (exception) {
                  showSnackbar(exception);
                }
              },
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

  Future<bool> moveFile(String uri, String fileName) async {
    String parentDir = (await getExternalStorageDirectory())!.absolute.path;
    final b =
        await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');

    showSnackbar('Moved file:$b');
    return b;
  }

  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              Text('id: $id'),
              Text('Token: ${info.authenticationToken}'),
              Text('Name${info.endpointName}'),
              Text('Incoming: ${info.isIncomingConnection}'),
              ElevatedButton(
                child: Text('Accept Connection'),
                onPressed: () {
                  Navigator.pop(context);
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
                        // showSnackbar(endid + ": " + str);
                        showSnackbar('명함 수신 완료');

                        if (str.contains(':')) {
                          // used for file payload as file payload is mapped as
                          // payloadId:filename
                          int payloadId = int.parse(str.split(':')[0]);
                          String fileName = (str.split(':')[1]);

                          if (map.containsKey(payloadId)) {
                            if (tempFileUri != null) {
                              moveFile(tempFileUri!, fileName);
                            } else {
                              showSnackbar("File doesn't exist");
                            }
                          } else {
                            //add to map if not already
                            map[payloadId] = fileName;
                          }
                        }
                      } else if (payload.type == PayloadType.FILE) {
                        showSnackbar('$endid: File transfer started');
                        tempFileUri = payload.uri;
                      }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      if (payloadTransferUpdate.status ==
                          PayloadStatus.IN_PROGRESS) {
                        print(payloadTransferUpdate.bytesTransferred);
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.FAILURE) {
                        print('failed');
                        showSnackbar('$endid: FAILED to transfer file');
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.SUCCESS) {
                        showSnackbar(
                            '$endid success, total bytes = ${payloadTransferUpdate.totalBytes}');

                        if (map.containsKey(payloadTransferUpdate.id)) {
                          //rename the file now
                          String name = map[payloadTransferUpdate.id]!;
                          moveFile(tempFileUri!, name);
                        } else {
                          //bytes not received till yet
                          map[payloadTransferUpdate.id] = '';
                        }
                      }
                    },
                  );
                },
              ),
              ElevatedButton(
                child: Text('Reject Connection'),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
