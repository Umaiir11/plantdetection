import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_model/controller.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'AI Flower Recognition',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: controller.pickImage,
            child: const Icon(Icons.image, color: Colors.black),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 10.0),
          FloatingActionButton(
            onPressed: controller.captureImage,
            child: const Icon(Icons.camera_alt, color: Colors.black),
            backgroundColor: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GetBuilder<HomeController>(
                  builder: (_) => controller.image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.file(
                      controller.image!,
                      height: Get.height * 0.55,
                      width: Get.width * 0.9,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Center(
                    child: Text(
                      'Please pick an image',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.white38,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                GetBuilder<HomeController>(
                  builder: (_) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      controller.recognizedLabel?.isNotEmpty ?? false
                          ? controller.recognizedLabel!
                          : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18.0, // Increased font size for better readability
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.white38,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
