// ignore_for_file: avoid_print

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI detection and zoom',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(
        cameras: cameras,
      ),
    );
  }
}

void showToast({required String message}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0);
}


// scaleW = widget.screenH / img.height * img.width;
// scaleH = widget.screenH;
// var difW = (scaleW - widget.screenW) / scaleW;
// x = (re["rect"]["x"] - difW / 2) * scaleW;
// w = re["rect"]["w"] * scaleW;
// if (re["rect"]["x"] < difW / 2) {
//   w -= (difW / 2 - re["rect"]["x"]) * scaleW;
// }
// y = re["rect"]["y"] * scaleH;
// h = re["rect"]["h"] * scaleH;