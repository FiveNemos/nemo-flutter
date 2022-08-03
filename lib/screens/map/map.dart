import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../models/map/cord.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
//
// import '../sharing/sharing_accept_page.dart';
import '../../providers/bottomBar.dart';
import '../mypage/profile_page.dart';
// import '../sharing/sharing_qr_page.dart';

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

  // var myId;
  // var latt;
  // var longg;
  // geolocator
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String lng = '', lat = '';
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();
    getLocation();
    checkUser();
  }

  getLocation() async {
    LatLng currentPostion;

    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // print(position.longitude); //Output: 80.24599079
    // print(position.latitude); //Output: 29.6593457

    // lng = position.longitude.toString();
    // lat = position.latitude.toString();

    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
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
        currentPostion = LatLng(position.latitude, position.longitude);
      });
    });
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
          print('temp:$temp');
        });

        // print(double.parse(userCord.lat));
        // print(double.parse(userCord.long));
        // print(userCord.user_id);
        // print('접속성공');
        print('true');
        return true;
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      print('에라이 에러');
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

  @override
  Widget build(BuildContext context) {
    checkPermissions();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NeMo',
          style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
          future: _future,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            print('snapshot');
            Set<Marker> markers = {};
            for (var e in userCord) {
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
                              builder: (context) => ProfilePage(
                                  friendId: e.user_id, currIndex: 1)));
                    },
                  ),
                  icon: BitmapDescriptor.defaultMarker));
            }
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15,
              ),
              markers: markers,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              onMapCreated: mapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
            );
          }),
      bottomNavigationBar: context
          .read<BottomNavigationProvider>()
          .bottomNavigationBarClick(1, context),
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
