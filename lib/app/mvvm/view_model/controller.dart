import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

import '../../configs/constants.dart';
import '../model/model.dart';



class HomeController extends GetxController {
  Interpreter? _interpreter;
  String? recognizedLabel = '';
  XFile? pickedImage;
  File? image;
  List<String> labels = [];

  @override
  void onInit() {
    super.onInit();
    loadModel();
    loadLabels();
  }

  Future<void> loadModel() async {
    log('Loading interpreter options...');
    final interpreterOptions = InterpreterOptions();
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }
    if (Platform.isIOS) {
      interpreterOptions.addDelegate(GpuDelegate());
    }

    log('Loading interpreter...');
    _interpreter = await Interpreter.fromAsset(AppConstants.modelPath, options: interpreterOptions);
  }

  Future<void> loadLabels() async {
    final String labelsData = await rootBundle.loadString(AppConstants.labelpath);
    labels = labelsData.split('\n').map((label) => label.trim()).where((label) => label.isNotEmpty).toList();
    log('Labels loaded: $labels');
  }

  Future<bool> pickImage() async {
    final storagePermission = await requestStoragePermission();
    if (storagePermission.isGranted) {
      pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        image = File(pickedImage!.path);
        await runModel(File(pickedImage!.path));
        return true;
      } else {
        debugPrint("Image picking canceled by the user");
        return false;
      }
    } else {
      debugPrint("Storage permission not granted");
      return false;
    }
  }

  Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.photos.request();
  }

  Future<void> runModel(File imageFile) async {
    if (_interpreter == null) {
      await loadModel();
      if (_interpreter == null) {
        print("Failed to load model!");
        return;
      }
    }
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final List<double> input = preprocessImage(imageBytes);
    const List<int> _inputShape = [1, 224, 224, 3];
    var inputShape = _inputShape;

    List<dynamic> inputTensor = List.generate(inputShape[0], (_) => input).reshape(inputShape);
    List<int> outputShape = _interpreter!.getOutputTensor(0).shape;
    List<List<double>> output = List<List<double>>.generate(outputShape[0], (_) => List<double>.filled(outputShape[1], 0.0));
    _interpreter!.run(inputTensor, output);
    recognizedLabel = processOutput(output)!;

    update();
  }

  String? processOutput(List<List<double>> output) {
    int predictedClassIndex = 0;
    double maxConfidence = 0.0;

    for (int i = 0; i < output[0].length; i++) {
      double confidence = output[0][i];
      if (confidence > maxConfidence) {
        maxConfidence = confidence;
        predictedClassIndex = i;
      }
    }

    if (maxConfidence > 0.5) { // You can adjust the threshold value
      String label = labels[predictedClassIndex];
      DetectedObject detectedObject = DetectedObject(label, (maxConfidence * 100).toStringAsFixed(2));
      return recognizedLabel = '$label (Confidence: ${(maxConfidence * 100).toStringAsFixed(2)})'; // Combine label and confidence
    } else {
      return recognizedLabel = 'This image data is currently outside my area of expertise. Try uploading an image of a flower!';
    }
  }

  List<double> preprocessImage(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    final resizedImage = img.copyResize(image!, width: 224, height: 224);
    final normalizedPixels = resizedImage.data.map((pixel) {
      final r = (img.getRed(pixel) / 255.0);
      final g = (img.getGreen(pixel) / 255.0);
      final b = (img.getBlue(pixel) / 255.0);
      return [r, g, b];
    }).expand((i) => i).toList();

    return normalizedPixels;
  }

  @override
  void onClose() {
    super.onClose();
    _interpreter?.close();
  }
}
