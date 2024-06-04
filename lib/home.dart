import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GetBuilder<HomeController>(
          builder: (_) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: controller.pickImage,
                  child: Text('Pick Image from Gallery'),
                ),
                if (controller.recognitionsList != null && controller.recognitionsList!.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.recognitionsList!.length,
                      itemBuilder: (context, index) {
                        var detection = controller.recognitionsList![index];
                        return ListTile(
                          title: Text(detection.label),
                          subtitle: Text(
                              'Confidence: ${(detection.confidence * 100).toStringAsFixed(2)}%'),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
