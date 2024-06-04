import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class DetectedObject {
  final String label;
  final double confidence;

  DetectedObject(this.label, this.confidence);
}

const String _modelPath = 'assets/plant_classification_model.tflite';

class HomeController extends GetxController {
  List<DetectedObject> recognitionsList = [];
  Interpreter? _interpreter;
  String? recognizedLabel = '';
  XFile? pickedImage;
  File? image;

  @override
  void onInit() {
    super.onInit();
    loadModel();
  }

  Future<void> loadModel() async {
    log('Loading interpreter options...');
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }

    // Use Metal Delegate
    if (Platform.isIOS) {
      interpreterOptions.addDelegate(GpuDelegate());
    }

    log('Loading interpreter...');
    _interpreter = await Interpreter.fromAsset(_modelPath, options: interpreterOptions);
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

    // Reshape input tensor based on constant input shape
    var inputTensor = List.generate(inputShape[0], (_) => input).reshape(inputShape);
    // Read and preprocess the image


    // Prepare output tensor
    var outputShape = _interpreter!.getOutputTensor(0).shape;
    var output = List<List<double>>.generate(outputShape[0], (_) => List<double>.filled(outputShape[1], 0.0));

    // Run the interpreter
    _interpreter!.run(inputTensor, output);

    // Process the output
    recognizedLabel = processOutput(output)!;

    update();
  }

  String? processOutput(List<List<double>> output) {


    // Assuming output shape [1, 5]
    int predictedClassIndex = 0;
    double maxConfidence = 0.0;

    for (var i = 0; i < output[0].length; i++) {
      double confidence = output[0][i];
      if (confidence > maxConfidence) {
        maxConfidence = confidence;
        predictedClassIndex = i;
      }
    }


    if (maxConfidence > 0.5) { // You can adjust the threshold value
      String label = _getLabel(predictedClassIndex);
      return  recognizedLabel = '$label (Confidence:  ${(maxConfidence * 100).toStringAsFixed(2)})'; // Combine label and confidence
    } else {
       return recognizedLabel = 'Unidentified';
    }
  }


  String _getLabel(int index) {
    const labels = ["Daisy", "Dandelion", "Rose", "Sunflower", "Tulip"];
    return labels[index];
  }

  // Preprocess the resized image
  List<double> preprocessImage(Uint8List imageBytes) {
    // Decode the image
    final image = img.decodeImage(imageBytes);
    // Resize the image to the model's input size (e.g., 224x224)
    final resizedImage = img.copyResize(image!, width: 224, height: 224);

    // Normalize the image
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
