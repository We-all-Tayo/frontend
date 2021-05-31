import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main.dart';
import 'startSheet.dart';
import 'features/camera.dart';
import 'features/callSystem.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

String distance = '';
String angle = '';

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer _timer;
  Future _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    camController = CameraController(cameras.first, ResolutionPreset.medium);
    _initializeControllerFuture = camController.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    camController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('우리 모두 타요'),
        centerTitle: true,
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _end();
          _showInputSheet(context);
        },
        tooltip: '실행',
        child: Icon(Icons.play_arrow_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _body() => Container(
        child: Center(
          child: Column(
            children: <Widget>[
              _outputWidget('거리', distance),
              _outputWidget('각도', angle),
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Expanded(
                        child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: CameraPreview(
                          camController,
                        ),
                      ),
                    ));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              // Expanded(
              // ),
            ],
          ),
        ),
      );

  Widget _outputWidget(String text, String value) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Text(
              text,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Container(
              width: 10,
            ),
            Text(
              '|',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Container(
              width: 10,
            ),
            Text(
              value,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
      ),
    );
  }

  _showInputSheet(BuildContext context) async {
    var result = await showModalBottomSheet(
        context: context, builder: (context) => StartSheetContent());

    if (result != null) {
      InputData input = result;
      _start(input.stationID, input.routeNumber);
    }
  }

  _start(int stationID, int routeNumber) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isWork) {
        callSystem(stationID, routeNumber).then((value) {
          if (value != null &&
              (value.distance != null && value.angle != null)) {
            if (value.angle < 0) {
              value.angle *= -1;
              setState((){
                angle = '왼쪽 ${value.angle}';
              });
            } else if (value.angle > 0) {
              setState((){
                angle = '오른쪽 ${value.angle}';
              });
            } else {
              setState(() {
                angle = '직진';
              });
            }
            setState(() {
              distance = value.distance.toString();
            });
          }
        });
      }
    });
  }

  _end() {
    if (isWork) {
      isWork = false;
      print('!!! isWork: $isWork'); // XXX
      _timer?.cancel();
    }
  }
}
