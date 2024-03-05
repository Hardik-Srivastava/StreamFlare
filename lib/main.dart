import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:stream_flare/routes/app_route_config.dart';
import 'package:stream_flare/signaling.dart';
import 'package:stream_flare/test.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'StreamFlare',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routeInformationParser: GoRouterConfig.router.routeInformationParser,
        routerDelegate: GoRouterConfig.router.routerDelegate,
        routeInformationProvider:
            GoRouterConfig.router.routeInformationProvider,
        debugShowCheckedModeBanner: false);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.id}) : super(key: key);
  String? id;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
    // textEditingController.text=widget.id;
    // roomId=widget.id;
    // Future.delayed(Duration.zero).then((value) {
    //    signaling.joinRoom(
    //                   textEditingController.text.trim(),
    //                   _remoteRenderer,
    //                 );
    // }).then((value) => setState(() {
    //                   print("heklo");
    //                 },));
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("room Id is");
    // print(widget.id);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("StreamFlare - WebRTC",style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor:Colors.white,
                      textStyle: TextStyle(color:Colors.white), // Text color
                      elevation: 5, // Elevation (shadow) of the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      padding: EdgeInsets.all(15), // Button padding
                    ),
                    onPressed: () {
                      signaling.openUserMedia(_localRenderer, _remoteRenderer);
                    },
                    child: Text("Open camera & microphone"),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor:Colors.white,
                      textStyle: TextStyle(color:Colors.white),
                      elevation: 5, // Elevation (shadow) of the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      padding: EdgeInsets.all(15), // Button padding
                    ),
                    onPressed: () async {
                      roomId = await signaling.createRoom(_remoteRenderer);
                      // textEditingController.text = roomId!;
                      print('Room Id thus created in the room is');
                      print(roomId);
                      setState(() {});
                    },
                    child: Text("Create room"),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
backgroundColor: Colors.blue, // Background color
foregroundColor:Colors.white,
                      textStyle: TextStyle(color:Colors.white),
                      elevation: 5, // Elevation (shadow) of the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      padding: EdgeInsets.all(15), // Button padding
                    ),
                    onPressed: () {
                      // Add roomId
                      signaling.joinRoom(
                        textEditingController.text.trim(),
                        _remoteRenderer,
                      );
                    },
                    child: Text("Join room"),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor:Colors.white,
                      textStyle: TextStyle(color:Colors.white),
                      elevation: 5, // Elevation (shadow) of the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      padding: EdgeInsets.all(15), // Button padding
                    ),
                    onPressed: () {
                      signaling.hangUp(_localRenderer);
                    },
                    child: Text("Hangup"),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: RTCVideoView(_localRenderer),
                  ),
                  Expanded(
                      child: RTCVideoView(
                    _remoteRenderer,
                    mirror: true,
                  )),
                ],
              ),
            ),
          ),
          if(roomId!=null)Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(border: Border.all(color: Colors.black),borderRadius: BorderRadius.circular(10)),
              child: Text('Room created with Id: ${roomId}',style: TextStyle(fontSize: 17, color: Colors.white),)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Join the following Room: ",
                  style: TextStyle(color: Colors.white),
                ),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
