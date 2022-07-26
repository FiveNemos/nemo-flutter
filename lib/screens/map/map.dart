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
  Map userCord = {};

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
    try {
      var dio = Dio();
      Response response = await dio.get('http://10.0.2.2:3000/api/friend/lat');

      if (response.statusCode == 200) {
        final json = response.data;
        print(json);
        // setState each 'connections'

        setState(() {
          userCord = UserCord(
              user_id: json['user_id'], lat: json['lat'], long: json['long']);
        });

        return userCord;
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
        title: const Text("User current location"),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
          // sleep(const Duration(milliseconds: 3000));

          // latt = double.parse(userCord[i].lat);
          // longg = double.parse(userCord[i].long);
          markers.add(
            Marker(
              markerId: MarkerId('test'),
              position: LatLng(36.392865, 127.398889),
              infoWindow: InfoWindow(
                title: '11111',
                snippet: '222',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
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
