import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../sharing/took_profile_sharing.dart';

class PunchPage extends StatefulWidget {
  PunchPage({Key? key, this.friendId}) : super(key: key);
  var friendId;

  @override
  _PunchPageState createState() => _PunchPageState();
}

class _PunchPageState extends State<PunchPage> {
  Color _backgroundColor = Color.fromARGB(255, 235, 238, 255);
  List<double>? _userAccelerometerValues;

  @override
  void initState() {
    super.initState();
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        // Manipulate the UI here, something like:
        if (event.y > 5 || event.y < -5) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(friendId: widget.friendId)));
          dispose();
        } else if (event.x < -5 || event.x > 5) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(friendId: widget.friendId)));
          dispose();
        } else {}
      });
    });
  }

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    // final userAccelerometer = _userAccelerometerValues
    //     ?.map((double v) => v.toStringAsFixed(1))
    //     .toList();

    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/bump_image.webp",
          width: 300,
          height: 300,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}
