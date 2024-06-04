import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
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
      floatingActionButton: FloatingActionButton(
        onPressed: controller.pickImage,
        child: const Icon(Icons.image, color: Colors.black),
        backgroundColor: Colors.white,
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
                          child: Image.file(height: 550, width: 400,  controller.image!),
                        )
                      : Center(
                        child: const Text(
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
                  builder: (_) => Text(
                    controller.recognizedLabel?.isNotEmpty ?? false
                        ?'${controller.recognizedLabel!}'
                        : '',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 15.0,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
