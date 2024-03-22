// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:realtimedetectionandzoom/customcamera.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // -------------------
    Tflite.close();
    // -------------------
    Tflite.loadModel(
      model: "assets/yolov2_tiny.tflite",
      labels: "assets/yolov2_tiny.txt",
    );
    // -------------------
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
            child: CustomCamera(
      cameras: widget.cameras,
      subject: "bottle",
      screenH: screen.height,
      screenW: screen.width,
    )));
  }
}
