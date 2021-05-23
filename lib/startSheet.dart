import 'package:flutter/material.dart';
import 'features/callSystem.dart';
import 'features/loadStationInfo.dart';

String _stationInfo = '정류장 (정류장ID)';
int stationID = 0;
int routeNumber = 0;

class StartSheetContent extends StatefulWidget {
  @override
  _StartSheetState createState() => _StartSheetState();
}

class _StartSheetState extends State<StartSheetContent> {
  TextEditingController _routeNumController = TextEditingController();
  double _latitude = 0.0;
  double _longitude = 0.0;

  bool _reloadActive = false;

  @override
  void initState() {
    super.initState();

    getCurrentLocation().then((location) => setState(() {
          _latitude = location.latitude;
          _longitude = location.longitude;

          loadStationInfo(_longitude, _latitude, 100)
              .then((station) => setState(() {
                    _stationInfo =
                        '${station.stationName} (${station.stationID})';
                    stationID = int.parse(station.stationID);
                    _reloadActive = true;
                  }));
        }));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.my_location),
                    color: Colors.blueAccent,
                    onPressed: _reloadActive ? () {
                      setState(() {
                        _reloadActive = false;
                      });
                      getCurrentLocation().then((location) => setState(() {
                            _latitude = location.latitude;
                            _longitude = location.longitude;

                            loadStationInfo(_longitude, _latitude, 100)
                                .then((station) => setState(() {
                                      _stationInfo =
                                          '${station.stationName} (${station.stationID})';
                                      stationID = int.parse(station.stationID);
                                      _reloadActive = true;
                                    }));
                          }));
                    } : null),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  width: MediaQuery.of(context).size.width - 68,
                  padding: EdgeInsets.all(10),
                  child: Text(_stationInfo, style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _routeNumController,
              keyboardType: TextInputType.numberWithOptions(
                decimal: false,
              ),
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  labelText: '노선 번호', border: OutlineInputBorder()),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                String _routeNumber = _routeNumController.value.text;
                if (_routeNumber != '') {
                  routeNumber = int.parse(_routeNumber);
                  isWork = true;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('시스템 시작'),
                  ));
                }
              },
              child: Text('실행하기'),
            ),
          ),
        ],
      ),
    );
  }
}
