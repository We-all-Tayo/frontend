import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import 'camera.dart';

const String BACKEND_SERVER = 'http://172.30.1.43:5000/task'; // FIXME

class ResultData {
  double distance;
  double angle;

  ResultData({this.distance, this.angle});

  ResultData.fromJson(Map data)
      : distance = data['distance'],
        angle = data['angle'];
}

bool isWork = false;

Future<ResultData> callSystem(int stationID, int routeNum) async {
  XFile imageFile = await takePicture();
  if (imageFile != null) {
    print('$stationID, $routeNum, ${imageFile.path}'); // XXX
    var bytes = io.File(imageFile.path).readAsBytesSync();
    print('!!! bytes: $bytes'); // XXX
    var response = await _post(stationID, routeNum, bytes);
    if (response.statusCode == 200) {
      print('!!! body: ${response.body}'); // XXX
      var jsonResult = json.decode(response.body);
      if (jsonResult['error'] != null) {
        print("ERROR: ${jsonResult['error']}"); // XXX
        return null;
      }
      return ResultData.fromJson(json.decode(response.body));
    } else {
      print('!!! ERROR ${response.statusCode}: ${response.headers}'); // XXX
    }
  }

  return null;
}

Future<http.Response> _post(int stationID, int routeNum, Uint8List image) {
  return http.post(
      Uri.parse(BACKEND_SERVER),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
      'bus': routeNum.toString(),
      'station': stationID.toString(),
      'image': image.toString(),
      })
  );
}