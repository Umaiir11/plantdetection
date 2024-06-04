import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mvvm/view/home.dart';



class PlantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}


