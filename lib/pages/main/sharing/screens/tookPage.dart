import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TookPage extends StatefulWidget {
  const TookPage({Key? key}) : super(key: key);

  @override
  _TookPageState createState() => _TookPageState();
}

class _TookPageState extends State<TookPage> {
  getData() async{
    var result = await http.get(Uri.parse('http://34.64.217.3:3000/ping'));
    print(jsonDecode(result.body));
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

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
                )
            )
        )
    );
  }
}

generateBlank() {
  return Container(
    height: 160, color: Colors.white,
    child: ListTile(),
  );
}
//
// generateCard() {
//   return Container(
//       height: 250,
//       child: Text('명함자리임',
//         style: TextStyle(
//           color: Colors.grey.shade500,
//           fontSize:30,
//           fontWeight:FontWeight.bold),
//       ),
//       decoration: BoxDecoration(
//         color: Color(0xff8effd7),
//       )
//   );
// }

generateCard(){
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
              child: Image.network("https://s3.us-west-2.amazonaws.com/secure.notion-static.com/234c130e-99c3-46ee-9f7e-df52627f5805/KakaoTalk_Photo_2022-07-04-10-44-49.gif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220713%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220713T120807Z&X-Amz-Expires=86400&X-Amz-Signature=0c0e9e00fdd1f9641333760e36aa428db3191d2b10681805fc6462963f7c4e4b&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22KakaoTalk_Photo_2022-07-04-10-44-49.gif%22&x-id=GetObject",
                  width: 300, height: 250, fit: BoxFit.fitWidth),
            ),
            ListTile(
              tileColor: Color(0xc7ffffff),
              dense: true,
              visualDensity: VisualDensity(vertical: 3),
              title: Text("고니고니",
                  style: TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold)),
              subtitle: Text("캣홀릭 오타쿠",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w300)),
            ),
          ],
        ),
      ),
    ),
  );
}

// generateCard() {
//   return Container(
//       height: 250,
//       child: Text('명함자리임',
//         style: TextStyle(
//             color: Colors.grey.shade500,
//             fontSize:30,
//             fontWeight:FontWeight.bold),
//       ),
//       decoration: BoxDecoration(
//         color: Color(0xff8effd7),
//       )
//   );
// }