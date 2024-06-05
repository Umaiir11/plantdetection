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
  String? recognizedLabel;
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
    try {
      final interpreterOptions = InterpreterOptions();
      if (Platform.isAndroid) {
        interpreterOptions.addDelegate(XNNPackDelegate());
      } else if (Platform.isIOS) {
        interpreterOptions.addDelegate(GpuDelegate());
      }
      _interpreter = await Interpreter.fromAsset(AppConstants.modelPath, options: interpreterOptions);
      debugPrint('Interpreter loaded successfully');
    } catch (e) {
      debugPrint('Failed to load interpreter: $e');
    }
  }

  Future<void> loadLabels() async {
    try {
      final String labelsData = await rootBundle.loadString(AppConstants.labelpath);
      labels = labelsData.split('\n').map((label) => label.trim()).where((label) => label.isNotEmpty).toList();
      debugPrint('Labels loaded: $labels');
    } catch (e) {
      debugPrint('Failed to load labels: $e');
    }
  }

  Future<bool> captureImage() async {
    final cameraPermission = await requestCameraPermission();
    if (cameraPermission.isGranted) {
      pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        image = File(pickedImage!.path);
        await runModel(image!);
        return true;
      } else {
        debugPrint("Image capture canceled by the user");
        return false;
      }
    } else {
      debugPrint("Camera permission not granted");
      return false;
    }
  }

  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.photos.request();
  }

  Future<bool> pickImage() async {
    final storagePermission = await requestStoragePermission();
    if (storagePermission.isGranted) {
      pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        image = File(pickedImage!.path);
        await runModel(image!);
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

  Future<void> runModel(File imageFile) async {
    if (_interpreter == null) {
      debugPrint('Interpreter not initialized');
      return;
    }

    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final input = preprocessImage(imageBytes);
      final output = await infer(input);
      recognizedLabel = processOutput(output);
      update();
    } catch (e) {
      debugPrint('Error running model: $e');
    }
  }

  Future<List<List<double>>> infer(List<double> input) async {
    const inputShape = [1, 224, 224, 3];
    final inputTensor = input.reshape(inputShape);
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final output = List<List<double>>.generate(outputShape[0], (_) => List<double>.filled(outputShape[1], 0.0));
    _interpreter!.run(inputTensor, output);
    return output;
  }

  String? processOutput(List<List<double>> output) {
    const threshold = 0.80;
    final maxConfidence = output[0].reduce((a, b) => a > b ? a : b);

    if (maxConfidence >= threshold) {
      final predictedClassIndex = output[0].indexOf(maxConfidence);
      final label = labels[predictedClassIndex];
      return '$label (Confidence: ${(maxConfidence * 100).toStringAsFixed(2)})';
    } else {
      return 'This image data is currently outside my area of expertise. Try uploading an image of a flower!';
    }
  }

  List<double> preprocessImage(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    final resizedImage = img.copyResize(image!, width: 224, height: 224);
    final normalizedPixels = resizedImage.data
        .map((pixel) => [img.getRed(pixel) / 255.0, img.getGreen(pixel) / 255.0, img.getBlue(pixel) / 255.0])
        .expand((i) => i)
        .toList();
    return normalizedPixels;
  }

  @override
  void onClose() {
    _interpreter?.close();
    super.onClose();
  }
}
