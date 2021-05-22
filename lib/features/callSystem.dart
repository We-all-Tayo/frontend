import 'package:camera/camera.dart';
import 'camera.dart';

class ResultData {
  double distance;
  double angle;

  ResultData({this.distance, this.angle});
}

bool isWork = false;

Future<ResultData> callSystem(int stationID, int routeNum) async {
  XFile imageFile = await takePicture();
  print('$stationID, $routeNum, ${imageFile.path}');

  // FIXME: Start the system

  return ResultData(distance: 0, angle: 0);

}