// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realtimedetectionandzoom/preview.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: IconButton(
        icon: const Icon(
          Icons.image,
          size: 32,
        ),
        color: Colors.white,
        onPressed: () async {
          XFile? image = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            imageQuality: 100,
          );
          if (mounted && image != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ImagePreview(file: File(image.path))));
          }
        },
      ),
    )));
  }
}
