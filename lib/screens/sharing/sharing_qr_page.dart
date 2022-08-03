import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nemo_flutter/screens/sharing/punch.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:convert';

import '../mypage/profile_page.dart';

// sharing.dart
// Sharing 페이지를 stateful widget으로 변경하기
// isQRmode = false 로 state 변수 추가하기
// isQRmode 를 ON/OFF 해주는 버튼을 actions:[]에 추가하기
// Draggable 클래스에 child: TookPage()와 함께 isQRmode : _isQRmode를 전달하기
// 삼항연산자로 드래그 시에 실행하는거 나누기.

/* 명함 보내는 중 ... !isQRmode ? (원래 동작 try-catch) : (QRforTOOK으로 Navigator.push => QR 생성자 모드로 보여주기) */
// 명함을 보내는 사람은 'QR${myId}' 라는 소켓 방에 접속해있도록 함
// 접속자가 2명이 되면, 즉 QR을 읽은 receiver가 자기 아이디를 emit해주면, 해당 내용을 확인하고 disconnect하고 PunchPage로 이동

/* 명함 받는 중 ... !isQRmode ? (원래 동작 try-catch) : (QRforTOOK으로 Navigator.push => QR 촬영 모드로 보여주기) */
// 명함을 받는 사람은 QR를 촬영한 후에, 담기는 데이터 (id) 를 기반으로 'QR${friendId}' 라는 소켓 방으로 접속
// 접속에 성공한 후에, 자기 아이디가 뭔지를 emit해주고, 1초 후에 disconnect 하고 PunchPage로 이동

class QRforTOOK extends StatefulWidget {
  QRforTOOK(
      {Key? key,
      required this.isSender,
      required this.myId,
      required this.latlng})
      : super(key: key);
  bool isSender;
  int? myId;
  List? latlng;

  @override
  State<QRforTOOK> createState() => _QRforTOOKState();
}

class _QRforTOOKState extends State<QRforTOOK> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  dynamic socket;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  initializeSocket() {
    try {
      socket = io('http://34.64.217.3:3000/', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket.connect();
      socket.on('connect', (data) {
        debugPrint('socket connected');
        if (widget.isSender) {
          socket.emit('join', 'QRTOOKExchange${widget.myId.toString()}');
        }
        debugPrint('연결완료');
      });

      socket.on('join', (data) {
        debugPrint('socket join');
      });

      socket.on('leave', (data) {
        debugPrint('socket leave');
      });

      socket.on('took', (data) {
        int friendId = widget.isSender ? data.receiverID : data.senderID;
        socket.emit('leave', data.chatroomID); // receiver, sender 공통
        socket.emit('disconnect');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PunchPage(friendId: friendId, latlng: widget.latlng)));
      });

      socket.on('disconnect', (data) {
        debugPrint('socket disconnected');
        socket.disconnect();
      });
      // socket.onDisconnect((_) => debugPrint('disconnect'));
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    initializeSocket();
    Future.delayed(Duration(milliseconds: 600), () async {
      await controller?.resumeCamera();
    });
    super.initState();
    var encodeId =
        stringToBase64.encode('QRTOOKExchange${widget.myId.toString()}');
    var decodeId = stringToBase64.decode(encodeId);
    print('encodeId: $encodeId');
    print('decodeId: $decodeId');
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    // if (Platform.isAndroid) {
    //   controller!.pauseCamera();
    // } else if (Platform.isIOS) {
    //   controller!.resumeCamera();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: widget.isSender
          ? Center(
              child: QrImage(
              data: stringToBase64
                  .encode('QRTOOKExchange${widget.myId.toString()}'),
              backgroundColor: Colors.white,
              size: 200,
            ))
          // child: Text("난 샌즈라고!!!"))
          : Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                  // " 이번엔 내가 찍기 " 버튼 만들기. (QR코드 읽혔는지를 감지할 수 있는지)
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: (result != null)
                        ? Text(
                            'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                        : Text('Scan a code'),
                  ),
                )
              ],
            ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      int senderId;
      String? chatRoomId = stringToBase64
          .decode(scanData.code!); // 'QRTOOKExchange${widget.myId.toString()}'
      String? senderIdinStr = chatRoomId.substring(14);
      senderId = int.parse(senderIdinStr);

      setState(() {
        result = scanData;
        socket.emit('join', chatRoomId);
        socket.emit('took', {
          'chatroomID': chatRoomId,
          'senderID': senderId,
          'receiverID': widget.myId
        }); // 칭구
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
