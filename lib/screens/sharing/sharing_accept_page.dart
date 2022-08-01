import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/physics.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../mypage/cardeditor.dart';
import '../../models/sharing/user.dart';
import '../mypage/profile_page.dart';
import '../sharing/punch.dart';
import 'package:dio/dio.dart';
import 'package:page_transition/page_transition.dart';

// geolocator
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

class SharingFriendPage extends StatefulWidget {
  SharingFriendPage(
      {Key? key, this.friendId, required this.currIndex, this.latlng})
      : super(key: key);
  int? currIndex;
  int? friendId;
  List? latlng;
  @override
  State<SharingFriendPage> createState() => _SharingFriendPageState();
}

class _SharingFriendPageState extends State<SharingFriendPage> {
  int? myId;
  dynamic userInfo = '';
  var friendDataFromJson;
  Map friendData = {};
  // bool accepted = false;
  // 친구의 명함을 가져옴
  getFriendCard(id) async {
    try {
      var dio = Dio();
      Response response = await dio.get('http://34.64.217.3:3000/api/card/$id');
      if (response.statusCode == 200) {
        friendData = response.data;
        setState(() {
          friendDataFromJson = User.fromJson(friendData); // Instance User
        });
        print('접속 성공!');
        return true;
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static final storage = FlutterSecureStorage();

  checkUser() async {
    dynamic userInfo = await storage.read(key: 'login');
    setState(() {
      myId = int.parse(jsonDecode(userInfo)['user_id']);
    });
    await getFriendCard(widget.friendId);
    // await getFriendCard(widget.friendId);
  }

  cancelExchange(context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              alignment: Alignment.center,
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            '${friendDataFromJson.nickname}님과 명함교환을 취소합니다.',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '정말 취소하시겠습니까? ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/contacts');
                            },
                            child: Text('Yes')),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('No')),
                      ],
                    )
                  ],
                ),
              ));
        });
  }

  saveFriend() async {
    var uri = Uri.parse(
        'http://34.64.217.3:3000/api/friend?id_1=$myId&id_2=${widget.friendId}&lat=${widget.latlng![0]}&lng=${widget.latlng![1]}');
    var request = http.MultipartRequest('GET', uri);

    final response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    checkUser();
    // getFriendCard(widget.friendId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'NeMo',
            style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Icon(Icons.keyboard_backspace_outlined),
              onPressed: () {
                cancelExchange(context);
              }),
        ),
        body: (friendDataFromJson != null)
            ? Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Container(
                                    // 여기에도 뭔가 다른 배경을 넣어주면 좋을듯.
                                    // decoration: BoxDecoration(
                                    //   image: DecorationImage(
                                    //     image: AssetImage(
                                    //         'assets/background.jpeg'),
                                    //     fit: BoxFit.cover,
                                    //   ),
                                    // ),
                                    child: Center(
                                  child: Container(
                                    padding:
                                        EdgeInsets.fromLTRB(15, 10, 15, 10),
                                    child: ListView(
                                      // scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: [
                                        Container(
                                          // height: 500,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 1.0,
                                                offset: Offset(2,
                                                    4), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .stretch, // add this
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  topRight:
                                                      Radius.circular(10.0),
                                                ),
                                                child: Image(
                                                  image: CachedNetworkImageProvider(
                                                      'https://storage.googleapis.com/nemo-bucket/${friendDataFromJson.image}'),
                                                  width: 300,
                                                  height: 240,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    15, 5, 15, 5),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        top: BorderSide(
                                                            color:
                                                                Colors.black))),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${friendDataFromJson.nickname}',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(width: 5),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.all(1),
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  7, 2, 7, 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xff8338EC),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Text(
                                                            '#${friendDataFromJson.tag_1}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),

                                                        Container(
                                                          margin:
                                                              EdgeInsets.all(1),
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  7, 1, 7, 1),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            border: Border.all(
                                                              width: 1.5,
                                                              color: Color(
                                                                  0xff8338EC),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            '#${friendDataFromJson.tag_2}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        //
                                                        Container(
                                                          margin:
                                                              EdgeInsets.all(1),
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  7, 2, 7, 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xff8338EC),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Text(
                                                            '#${friendDataFromJson.tag_3}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      '${friendDataFromJson.intro}',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${friendDataFromJson.nickname}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 27,
                                          fontWeight: FontWeight.w900,
                                        )),
                                    Text(' 님의',
                                        style: TextStyle(
                                            color: Color(0xff6a4cb7),
                                            fontSize: 21,
                                            fontWeight: FontWeight.w900)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '명함이 도착했어요 🙌',
                                      style: TextStyle(
                                          color: Color(0xff6a4cb7),
                                          fontSize: 21,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                bool saveResult = await saveFriend();
                                // bool saveResult = true;
                                // bool saveResult = true; // 저장에 성공했습니다 🙌
                                if (saveResult) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return WillPopScope(
                                          onWillPop: () {
                                            return Future.value(false);
                                          },
                                          child: Dialog(
                                              alignment: Alignment.center,
                                              child: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    5, 10, 5, 10),
                                                height: 300,
                                                width: 300,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          '${friendDataFromJson.nickname}',
                                                          style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                          ),
                                                        ),
                                                        Text(
                                                          ' 님과',
                                                          style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xff6a4cb7),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      '명함을 교환했어요',
                                                      style: TextStyle(
                                                        fontSize: 21,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6a4cb7),
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 10, 0, 10)),
                                                    Text(
                                                      '🤜🏼 🤛🏼',
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 10, 0, 10)),
                                                    Text(
                                                      '프로필을 보며\n서로를 알아가보세요!',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .grey.shade600),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 10, 0, 10)),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .rotate,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              400),
                                                                      child:
                                                                          ProfilePage(
                                                                        friendId:
                                                                            widget.friendId,
                                                                        currIndex:
                                                                            1,
                                                                      ))
                                                                  // MaterialPageRoute(
                                                                  //     builder: (context) =>
                                                                  //         ProfilePage(
                                                                  //           friendId:
                                                                  //               widget.friendId,
                                                                  //           currIndex:
                                                                  //               1,
                                                                  //         ))
                                                                  );
                                                            },
                                                            child: Text(
                                                              '프로필 보기',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            )),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  '/contacts');
                                                            },
                                                            child: Text(
                                                              '나중에 보기',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ))
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        );
                                      });
                                  // 명함첩으로 이동
                                  // 저장에 성공했습니다 띄울까
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                            alignment: Alignment.center,
                                            child: Container(
                                                height: 100,
                                                width: 100,
                                                alignment: Alignment.center,
                                                child: Text(
                                                    '저장에 실패했습니다😓 다시 시도해주세요.')));
                                      });
                                  // Navigator.pop(context);
                                }

                                DialogUI(
                                  popFor: 'save',
                                  myId: myId,
                                  friendId: widget.friendId,
                                  latlng: widget.latlng,
                                  friendName: friendDataFromJson.nickname,
                                );
                              },
                              child: Text(
                                '반가워요 !',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                cancelExchange(context);
                              },
                              child: Text(
                                '누구세요..?',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}
//
// class FriendCardPage extends StatefulWidget {
//   FriendCardPage(
//       {Key? key,
//       this.friendDataFromJson,
//       this.cancelExchange,
//       required this.myId,
//       required this.friendId,
//       required this.latlng})
//       : super(key: key);
//   var friendDataFromJson;
//   var cancelExchange;
//   int myId;
//   int friendId;
//   List latlng;
//
//   @override
//   State<FriendCardPage> createState() => _FriendCardPageState();
// }
//
// class _FriendCardPageState extends State<FriendCardPage> {
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () {
//         return Future.value(false);
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           title: Text(
//             'NeMo',
//             style: TextStyle(fontFamily: 'CherryBomb', fontSize: 30),
//           ),
//           centerTitle: true,
//           automaticallyImplyLeading: false,
//           leading: IconButton(
//               icon: Icon(Icons.keyboard_backspace_outlined),
//               onPressed: () {
//                 widget.cancelExchange(context);
//               }),
//           actions: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(fixedSize: Size(40, 40)),
//               child: Text('저장'),
//               onPressed: () {
//                 showDialog(
//                     context: context,
//                     builder: (context) {
//                       return DialogUI(
//                         popFor: 'save',
//                         myId: widget.myId,
//                         friendId: widget.friendId,
//                         latlng: widget.latlng,
//                         friendName: widget.friendDataFromJson.nickname,
//                       );
//                     });
//                 // POST CONNECTION
//               },
//             ),
//           ],
//         ),
//         body: Container(
//             // 여기에도 뭔가 다른 배경을 넣어주면 좋을듯.
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/background.jpeg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Center(
//               child: Container(
//                 padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
//                 child: ListView(
//                   // scrollDirection: Axis.vertical,
//                   physics: NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   children: [
//                     Container(
//                       // height: 500,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: Colors.black),
//                         borderRadius: BorderRadius.circular(10),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 1,
//                             blurRadius: 1.0,
//                             offset: Offset(2, 4), // changes position of shadow
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.stretch, // add this
//                         children: <Widget>[
//                           ClipRRect(
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(10.0),
//                               topRight: Radius.circular(10.0),
//                             ),
//                             child: Image(
//                               image: CachedNetworkImageProvider(
//                                   'http://34.64.217.3:3000/static/${widget.friendDataFromJson.image}'),
//                               width: 300,
//                               height: 240,
//                               fit: BoxFit.fitWidth,
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
//                             decoration: BoxDecoration(
//                                 border: Border(
//                                     top: BorderSide(color: Colors.black))),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(
//                                       '${widget.friendDataFromJson.nickname}',
//                                       style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Padding(
//                                         padding:
//                                             EdgeInsets.fromLTRB(0, 0, 8, 0)),
//                                     Container(
//                                       padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
//                                       decoration: BoxDecoration(
//                                         color: Color(0xff8338EC),
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: Text(
//                                         '#${widget.friendDataFromJson.tag_1}',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                         padding:
//                                             EdgeInsets.fromLTRB(0, 0, 8, 0)),
//                                     Container(
//                                       padding: EdgeInsets.fromLTRB(7, 1, 7, 1),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(12),
//                                         border: Border.all(
//                                           width: 1.5,
//                                           color: Color(0xff8338EC),
//                                         ),
//                                       ),
//                                       child: Text(
//                                         '#${widget.friendDataFromJson.tag_2}',
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                         padding:
//                                             EdgeInsets.fromLTRB(0, 0, 8, 0)),
//                                     Container(
//                                       padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
//                                       decoration: BoxDecoration(
//                                         color: Color(0xff8338EC),
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: Text(
//                                         '#${widget.friendDataFromJson.tag_3}',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Text(
//                                   '${widget.friendDataFromJson.intro}',
//                                   style: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )),
//         // bottomNavigationBar: BottomNavigationBar(
//         //   type: BottomNavigationBarType.fixed,
//         //   items: [
//         //     BottomNavigationBarItem(
//         //       icon: Icon(Icons.contacts),
//         //       label: '연락처',
//         //     ),
//         //     BottomNavigationBarItem(
//         //       icon: Icon(Icons.share),
//         //       label: '공유',
//         //     ),
//         //     BottomNavigationBarItem(
//         //       icon: Icon(Icons.map),
//         //       label: 'Map',
//         //     ),
//         //     BottomNavigationBarItem(
//         //       icon: Icon(Icons.message),
//         //       label: '메시지',
//         //     ),
//         //     BottomNavigationBarItem(
//         //       icon: Icon(Icons.person),
//         //       label: '마이페이지',
//         //     ),
//         //   ],
//         //   currentIndex: 1,
//         //   onTap: (int index) {
//         //     if (index != 1) {
//         //       showDialog(
//         //           context: context,
//         //           builder: (context) {
//         //             return Dialog(
//         //                 alignment: Alignment.center,
//         //                 child: SizedBox(
//         //                   height: 200,
//         //                   width: double.infinity,
//         //                   child: Column(
//         //                     mainAxisAlignment: MainAxisAlignment.center,
//         //                     children: [
//         //                       Padding(
//         //                         padding: const EdgeInsets.all(20.0),
//         //                         child: Text(
//         //                             '${friendDataFromJson.nickname}님과 명함교환을 취소합니다. \n정말 취소하시겠습니까? '),
//         //                       ),
//         //                       Row(
//         //                         mainAxisAlignment: MainAxisAlignment.center,
//         //                         children: [
//         //                           TextButton(
//         //                               onPressed: () {
//         //                                 switch (index) {
//         //                                   case 0:
//         //                                     Navigator.pushNamed(
//         //                                         context, '/contacts');
//         //                                     break;
//         //                                   case 2:
//         //                                     Navigator.pushNamed(
//         //                                         context, '/map');
//         //                                     break;
//         //                                   case 3:
//         //                                     Navigator.pushNamed(
//         //                                         context, '/message');
//         //                                     break;
//         //                                   case 4:
//         //                                     Navigator.pushNamed(
//         //                                         context, '/mypage');
//         //                                     break;
//         //                                 }
//         //                               },
//         //                               child: Text('Yes')),
//         //                           TextButton(
//         //                               onPressed: () {
//         //                                 Navigator.pop(context);
//         //                               },
//         //                               child: Text('No')),
//         //                         ],
//         //                       )
//         //                     ],
//         //                   ),
//         //                 ));
//         //           });
//         //     }
//         //   },
//         // ),
//       ),
//     );
//   }
// }

class DialogUI extends StatelessWidget {
  DialogUI(
      {Key? key,
      required this.popFor,
      this.myId,
      this.friendId,
      this.latlng,
      this.friendName})
      : super(key: key);
  String popFor;
  int? myId;
  int? friendId;
  List? latlng;
  String? friendName;

  var inputData = TextEditingController();
  saveCardDecoration(labelText) {
    return InputDecoration(
      constraints: BoxConstraints(maxHeight: 45),
      labelText: labelText,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: Color(0xff8338EC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: Color(0xff8338EC),
        ),
      ),
    );
  }

  saveFriend() async {
    var uri = Uri.parse(
        'http://34.64.217.3:3000/api/friend?id_1=$myId&id_2=$friendId&lat=${latlng![0]}&lng=${latlng![1]}');
    var request = http.MultipartRequest('GET', uri);

    final response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      child: SizedBox(
          height: 150,
          width: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 70,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: TextField(
                  decoration: saveCardDecoration('어떤 모임에서 교환하셨나요?'),
                  controller: inputData,
                  maxLength: 15,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (inputData.text.isNotEmpty) {
                        bool saveResult = await saveFriend();
                        // bool saveResult = true; // 저장에 성공했습니다 🙌
                        if (saveResult) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return WillPopScope(
                                  onWillPop: () {
                                    return Future.value(false);
                                  },
                                  child: Dialog(
                                      alignment: Alignment.center,
                                      child: Container(
                                        margin:
                                            EdgeInsets.fromLTRB(5, 10, 5, 10),
                                        height: 300,
                                        width: 300,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '$friendName',
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                Text(
                                                  ' 님과',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff6a4cb7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '명함을 교환했어요',
                                              style: TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff6a4cb7),
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 10)),
                                            Text(
                                              '🤜🏼 🤛🏼',
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 10)),
                                            Text(
                                              '프로필을 보며\n서로를 알아가보세요!',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade600),
                                              textAlign: TextAlign.center,
                                            ),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 10)),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      ProfilePage(
                                                                        friendId:
                                                                            friendId,
                                                                        currIndex:
                                                                            1,
                                                                      )));
                                                    },
                                                    child: Text(
                                                      '프로필 보기',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                          context, '/contacts');
                                                    },
                                                    child: Text(
                                                      '나중에 보기',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ))
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                );
                              });
                          // 명함첩으로 이동
                          // 저장에 성공했습니다 띄울까
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                    alignment: Alignment.center,
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        alignment: Alignment.center,
                                        child:
                                            Text('저장에 실패했습니다😓 다시 시도해주세요.')));
                              });
                          // Navigator.pop(context);
                        }
                      }
                    },
                    child: Text('저장'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('취소'),
                  )
                ],
              )
            ],
          )),
    );
  }
}
