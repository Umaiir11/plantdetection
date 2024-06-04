import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800], // Maintain a sleek dark background
      body: SafeArea(
        child: SingleChildScrollView( // Allow content to scroll if needed
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0), // Consistent padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
              children: [
                // Title with a prominent Google AI-inspired font
                Text(
                  'AI Image Recognition',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ProductSans', // Modern Google font
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20.0), // Consistent spacing

                // Image section with professional presentation
                Stack(
                  alignment: Alignment.center, // Center content within stack
                  children: [
                    // Container with rounded corners for image background
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7, // Adaptive image size
                      height: MediaQuery.of(context).size.width * 0.7, // Maintain aspect ratio
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Colors.grey[200], // Subtle background for non-picked state
                      ),
                      child: ClipRRect( // Clip image within rounded container
                        borderRadius: BorderRadius.circular(16.0),
                        child: GetBuilder<HomeController>(
                          builder: (_) => controller.image != null
                              ? Image.file( controller.image! )
                              : const Center(
                            child: Text(
                              'No image picked yet.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Pick image button with a hover effect (optional)
                    ElevatedButton(
                      onPressed: controller.pickImage,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0), // Circular button
                        ), backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(16.0), // Maintain consistent color scheme
                      ),
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0), // Spacing between image and prediction

                // Prediction text with a subtle glow, inspired by Google AI style
                GetBuilder<HomeController>(
                  builder: (_) => Text(
                    controller.recognizedLabel != null &&
                        controller.recognizedLabel!.isNotEmpty
                        ? 'Prediction: ${controller.recognizedLabel}'
                        : '',
                    style: TextStyle(
                      fontFamily: 'ProductSans', // Modern Google font
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.white70,
                          offset: const Offset(1.0, 1.0),
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
