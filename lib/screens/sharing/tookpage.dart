import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TookPage extends StatefulWidget {
  const TookPage({Key? key}) : super(key: key);

  @override
  _TookPageState createState() => _TookPageState();
}

class _TookPageState extends State<TookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                color: Colors.white,
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    generateBlank(),
                    generateCard(),
                    generateBlank(),
                  ],
                ))));
  }
}

generateBlank() {
  return Container(
    height: 250,
    color: Colors.white,
    child: ListTile(),
  );
}

generateCard() {
  return Container(
    margin: EdgeInsets.all(8.0),
    // decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: InkWell(
        onTap: () => print("test"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // add this
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: Image.network(
                  "http://34.64.217.3:3000/static/gonigoni.gif",
                  width: 300,
                  height: 250,
                  fit: BoxFit.fitWidth),
            ),
            ListTile(
              tileColor: Color(0xc7ffffff),
              dense: true,
              visualDensity: VisualDensity(vertical: 3),
              title: Text("고니고니",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              subtitle: Text("캣홀릭 오타쿠",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
            ),
          ],
        ),
      ),
    ),
  );
}
