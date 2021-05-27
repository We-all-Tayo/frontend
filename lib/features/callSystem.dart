import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import 'camera.dart';

const String BACKEND_SERVER = 'http://192.168.35.223:5000/task'; // FIXME

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
    var bytes = io.File(imageFile.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    var response = await _post(stationID, routeNum, img64);
    if (response.statusCode == 200) {
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

Future<http.Response> _post(int stationID, int routeNum, String image) {
  return http.post(
      Uri.parse(BACKEND_SERVER),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
      'bus': routeNum.toString(),
      'station': stationID.toString(),
      'image': image,
      })
  );
}