import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shimmer/shimmer.dart';

import 'package:nemo_flutter/screens/mypage/profile_page.dart';

class PunchPage extends StatefulWidget {
  PunchPage({Key? key, this.friendId}) : super(key: key);
  var friendId;

  @override
  _PunchPageState createState() => _PunchPageState();
}

class _PunchPageState extends State<PunchPage> {
  final Color _backgroundColor = Color.fromARGB(255, 255, 255, 255);
  List<double>? _userAccelerometerValues;
  var cnt = 0;

  @override
  void initState() {
    // super.initState();
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        // Manipulate the UI here, something like:
        if ((event.y > 5 || event.y < -5) && cnt == 0) {
          cnt++;

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(friendId: widget.friendId)));
        } else if ((event.x < -5 || event.x > 5) && cnt == 0) {
          cnt++;

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(friendId: widget.friendId)));
        } else {}
        super.dispose();
        for (final subscription in _streamSubscriptions) {
          subscription.cancel();
        }
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
      body: ListView(
        children: [
          Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  SizedBox(
                    width: 350.0,
                    height: 100.0,
                    child: Shimmer.fromColors(
                      baseColor: Colors.red,
                      highlightColor: Colors.yellow,
                      child: Text(
                        'TooK !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 70.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Image.asset(
                    'assets/bump_hand.gif',
                    width: 700,
                    // height: 500,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: 350.0,
                    height: 100.0,
                    child: Shimmer.fromColors(
                      baseColor: Color.fromARGB(255, 23, 104, 255),
                      highlightColor: Colors.yellow,
                      child: Text(
                        'to Share !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
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
