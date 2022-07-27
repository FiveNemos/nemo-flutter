import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dio/dio.dart';
import '../../models/map/cord.dart';
import 'dart:convert';

//
// import '../sharing/sharing_profile_page.dart';
// import '../mypage/profile_page.dart';
import '../sharing/map_profile_page.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  Future? _future;
  Future<bool> loadString(id) async => await getCord(id);
  static final storage = FlutterSecureStorage();
  dynamic userInfo = '';
  List userCord = [];

  var loginID;
  // var myId;
  // var latt;
  // var longg;

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  getCord(id) async {
    // print('http://10.0.2.2:3000/api/friend/lat');
    try {
      var dio = Dio();
      Response response =
          await dio.get('http://34.64.217.3:3000/api/friend/map?user_id=$id');
      if (response.statusCode == 200) {
        final json = response.data['result'];
        // print(json.runtimeType);
        // print(userCord);
        // for (int i = 0; i < json.length; i++) {
        //   setState(() {
        //     userCord[i] = UserCord(
        //         user_id: json[i]['user_id'],
        //         lat: json[i]['lat'],
        //         long: json[i]['lng']);
        //   });
        //   print(userCord[0].lng);
        //
        //   print(userCord[i].user_id);
        //   print(userCord[i].lat);
        //   print(userCord[0].long);
        //   // }
        // }

        var temp = [];
        json.forEach((e) {
          temp.add(UserCord(
              user_id: e['user_id'],
              lat: e['lat'],
              long: e['lng'],
              date: e['connection_date'],
              nickname: e['nickname']));
        });
        setState(() {
          userCord = temp;
          print("temp:$temp");
        });

        // print(double.parse(userCord.lat));
        // print(double.parse(userCord.long));
        // print(userCord.user_id);
        // print('접속성공');
        print("true");
        return true;
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      print("에라이 에러");
      return false;
    }
  }

  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      loginID = jsonDecode(userInfo)['user_id'];
    });
    _future = loadString(loginID);
  }

  GoogleMapController? googleMapController;

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(36.392865, 127.398889), zoom: 17);
  //
  // Set<Marker> markers = {
  //   Marker(
  //     markerId: MarkerId('1'),
  //     // position: LatLng(latt, longg),
  //     position: LatLng(36.392865, 127.398889),
  //     // infoWindow: InfoWindow(
  //     //   title: '${userCord.user_id}',
  //     //   snippet: '${userCord.lat}, ${userCord.long}',
  //     // ),
  //     icon: BitmapDescriptor.defaultMarker,
  //   )
  // }; //

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
      body: FutureBuilder(
          future: _future,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            print("snapshot");
            Set<Marker> markers = {};
            userCord.forEach((e) {
              var latt = double.parse(e.lat);
              var long = double.parse(e.long);
              markers.add(Marker(
                  markerId: MarkerId(e.user_id.toString()),
                  position: LatLng(latt, long),
                  infoWindow: InfoWindow(
                    title: e.nickname,
                    snippet: e.date.split('T')[0],
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePage(friendId: e.user_id)));
                    },
                  ),
                  icon: BitmapDescriptor.defaultMarker));
            });
            return GoogleMap(
              initialCameraPosition: initialCameraPosition,
              markers: markers,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              onMapCreated: mapCreated,
            );
          }),
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

  void mapCreated(controller) {
    setState(() {
      googleMapController = controller;
    });
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
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}
