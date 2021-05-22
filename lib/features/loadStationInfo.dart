import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

class StationInfo {
  String stationName;
  String stationID;

  StationInfo({this.stationName, this.stationID});

  StationInfo.fromJson(Map data)
      : stationName = data['stationNm'],
        stationID = data['arsId'];
}

Future<StationInfo> loadStationInfo(double tmX, double tmY, int radius) async {
  String _authKey =
      'qiL4ea0xNUw+1eeYlMAZ7JscEL4RINlmM8HpbsxzK/PN2k3ttiWvy88nQ76HdNvLzrCpnhCuU5nF1VlyCzAkmA==';
  var url = Uri.http('ws.bus.go.kr', '/api/rest/stationinfo/getStationByPos', {
    'serviceKey': '$_authKey',
    'tmX': '$tmX',
    'tmY': '$tmY',
    'radius': '$radius'
  });

  var response = await http.get(url);
  if (response.statusCode == 200) {
    var transformer = Xml2Json();
    transformer.parse(response.body);
    var body = jsonDecode(transformer.toParker());
    if (body['ServiceResult']['msgHeader']['headerCd'] == '0') {
      var list = body['ServiceResult']['msgBody']['itemList'];
      return StationInfo.fromJson(list[0]);
    } else {
      print(body['ServiceResult']['msgHeader']['headerMsg']);
    }
  } else {
    print(response.statusCode);
  }
  return null;
}

Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}
