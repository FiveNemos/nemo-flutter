import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dio/dio.dart';
import '../../models/map/cord.dart';
import 'dart:convert';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  List userCord = [];

  var nowId;
  // var myId;
  var latt;
  var longg;

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  getCord(id) async {
    // print('http://10.0.2.2:3000/api/friend/lat');

    try {
      var dio = Dio();
      Response response =
          await dio.get('http://10.0.2.2:3000/api/friend/locs?user_id=6');
      if (response.statusCode == 200) {
        final json = response.data;

        print(json);
        setState(() {
          userCord = json;
        });
        print('111111');
        print(userCord);
        for (int i = 0; i < json.length; i++) {
          setState(() {
            userCord[i] = UserCord(
                user_id: json[i]['user_id'],
                lat: json[i]['lat'],
                long: json[i]['lng']);
          });
          print(userCord[0].lng);

          print(userCord[i].user_id);
          print(userCord[i].lat);
          print(userCord[0].long);
          // }
        }

        // print(double.parse(userCord.lat));
        // print(double.parse(userCord.long));
        // print(userCord.user_id);
        // print('접속성공');

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
    await getCord(nowId);
  }

  late GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(36.392865, 127.398889), zoom: 14);

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nemo',
          style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
          // sleep(const Duration(milliseconds: 3000));

          for (var i = 0; i < userCord.length; i++) {
            latt = double.parse(userCord[i].lat);
            longg = double.parse(userCord[i].long);
            markers.add(
              Marker(
                markerId: MarkerId(userCord[i].user_id),
                position: LatLng(latt, longg),
                // infoWindow: InfoWindow(
                //   title: '${userCord.user_id}',
                //   snippet: '${userCord.lat}, ${userCord.long}',
                // ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          }
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     Position position = await _determinePosition();

      //     googleMapController.animateCamera(CameraUpdate.newCameraPosition(
      //         CameraPosition(
      //             target: LatLng(
      //                 double.parse(userCord.lat), double.parse(userCord.long)),
      //             zoom: 14)));

      //     markers.clear();

      //     markers.add(Marker(
      //         markerId: const MarkerId('NeMo'),
      //         position: LatLng(
      //             double.parse(userCord.lat), double.parse(userCord.long))));

      //     // setState(() {});

      //     print('------------------');
      //     print(double.parse(userCord.lat));
      //     print(double.parse(userCord.long));
      //     print('------------------');
      //   },
      //   label: const Text("Current Location"),
      //   icon: const Icon(Icons.location_history),
      // ),
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
            icon: Icon(Icons.map),
            label: 'Map',
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
        currentIndex: 2,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/contacts');
              break;
            case 1:
              Navigator.pushNamed(context, '/sharing');
              break;
            case 2:
              // Navigator.pushNamed(context, '/map');
              break;
            case 3:
              Navigator.pushNamed(context, '/message');
              break;
            case 4:
              Navigator.pushNamed(context, '/mypage');
              break;
          }
        },
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}
