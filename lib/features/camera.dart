import 'package:camera/camera.dart';

CameraController camController;

Future<XFile> takePicture() async {
  if (camController.value.isTakingPicture) {
    return null;
  }

  try {
    XFile file = await camController.takePicture();
    return file;
  } on CameraException {
    return null;
  }
}
