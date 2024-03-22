import 'dart:io';

import 'package:flutter/material.dart';
import 'package:realtimedetectionandzoom/main.dart';
import 'package:tflite/tflite.dart';

class ImagePreview extends StatefulWidget {
  final File file;
  const ImagePreview({super.key, required this.file});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  List<dynamic>? parameters, recog;
  late double height, width;

  @override
  void initState() {
    FileImage(widget.file)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        height = info.image.height.toDouble();
        width = info.image.width.toDouble();
      });
    }));
    yoloDetect(widget.file).then((value) {
      findSubjectCoordinates(widget.file, recog!);
    });
    super.initState();
  }

  Future<void> yoloDetect(File image) async {
    List<dynamic>? recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "YOLO",
      threshold: 0.3,
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 1,
    );
    setState(() {
      recog = recognitions;
    });
  }

  findSubjectCoordinates(File image, List<dynamic>? list) {
    if (list == null || list.isEmpty) {
      showToast(message: "No subject is recognized");
      setState(() {
        parameters = null;
      });
    } else {
      final ele = list.firstWhere(
          (element) => element["detectedClass"] == "car",
          orElse: () => null);

      if (ele == null) {
        showToast(message: "No car is recognized");
        setState(() {
          parameters = [];
        });
      } else {
        setState(() {
          parameters = [
            ele["rect"]["x"], //x
            ele["rect"]["y"], //y
            ele["rect"]["w"], //x
            ele["rect"]["h"], //y
            double.parse(width.toString()),
            double.parse(height.toString())
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent(Size screen) {
      double factorX = screen.width;
      double factorY = height / width * screen.width;
      if (parameters == null || parameters!.isEmpty) {
        return Image.file(
          widget.file,
        );
      } else {
        // calculate image height, width wrt width available
        // print(parameters![2]);
        // print(1 / parameters![2]);
        // print(parameters![3]);
        // print(1 / parameters![3]);
        
        Matrix4 mtx = Matrix4.identity();
        mtx.translate((1 / parameters![2]) * parameters![0] * factorX * -1,
            (1 / parameters![3]) * parameters![1] * factorY * -1);
        mtx.scale(1 / parameters![2], 1 / parameters![3]);

        return InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          transformationController: TransformationController()..value = mtx,
          child: Image.file(
            widget.file,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Scaffold(
        body: SafeArea(
      child: Center(
          child: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 5)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return bodyContent(MediaQuery.of(context).size);
          } else {
            return const SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            );
          }
        },
      )),
    ));
  }
}
