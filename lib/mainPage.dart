import 'dart:io';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    camController = CameraController(cameras[0], ResolutionPreset.max);
    camController.initialize().then((_) {
      if (!mounted) {
        return;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    camController?.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          isWork = false;
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
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '거리',
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
                        distance,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '각도',
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
                        angle,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: CameraPreview(
                        camController,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  _showInputSheet(BuildContext context) async {
    await showModalBottomSheet(
        context: context, builder: (context) => StartSheetContent());

    if (isWork) {
      callSystem(stationID, routeNumber).then((value) {
        if (value != null) {
          setState(() {
            distance = value.distance.toString();
            angle = value.angle.toString();
          });
        }
      });
    }
  }

}
