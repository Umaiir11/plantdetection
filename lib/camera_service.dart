import 'package:camera/camera.dart';

class CameraService {
  static Future<List<CameraDescription>> getAvailableCameras() async {
    return await availableCameras();
  }
}