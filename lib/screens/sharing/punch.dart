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
        } else if (event.x < -5 || event.x > 5) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(friendId: widget.friendId)));
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
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
                top: (MediaQuery.of(context).size.height) / 2 - 60),
            child: Text(
              'test',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 100,
                // initstate color
              ),
            ),
          ),
        ],
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
