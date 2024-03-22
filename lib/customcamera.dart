// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:realtimedetectionandzoom/main.dart';
import 'package:tflite/tflite.dart';

class CustomCamera extends StatefulWidget {
  const CustomCamera({
    super.key,
    required this.cameras,
    required this.subject,
    required this.screenH,
    required this.screenW,
  });

  final List<CameraDescription>? cameras;
  final String subject;
  final double screenH;
  final double screenW;

  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera> {
  late CameraController controller;
  bool isDetecting = false;
  double scaleX = 1.0, scaleY = 1.0, x = 0.5, y = 0.5, w = 0.5, h = 0.5;

  @override
  void initState() {
    if (widget.cameras == null || widget.cameras!.isEmpty) {
      print('No camera is found');
    } else {
      controller = CameraController(
        widget.cameras![0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void detect() {
    controller.startImageStream((CameraImage img) {
      if (!isDetecting) {
        isDetecting = true;
        Tflite.detectObjectOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          model: "YOLO",
          imageHeight: img.height,
          imageWidth: img.width,
          imageMean: 0,
          imageStd: 255.0,
          numResultsPerClass: 1,
          threshold: 0.2,
        ).then((recognitions) {
          print(recognitions.toString());
          if (recognitions != null) {
            final re = recognitions.firstWhere(
                (element) => element["detectedClass"] == widget.subject,
                orElse: () => null);
            if (re != null) {
              
              w = re["rect"]["w"] * img.width;
              h = re["rect"]["h"] * img.height;
              x = re["rect"]["x"] * img.width;
              y = re["rect"]["y"] * img.height;

              double subjectAspectRatio = w / h;
              double viewportAspectRatio = img.width / img.height;

              if (subjectAspectRatio > viewportAspectRatio) {
                // Fit to width
                scaleX = img.width / w;
                scaleY = scaleX;
              } else {
                // Fit to height
                scaleY = img.height / h;
                scaleX = scaleY;
              }

              print("$scaleX $scaleY $x $y $w $h");
              setState(() {});
            }
          } else {
            showToast(message: "No regognitions found");
          }
          isDetecting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(
        child: Text("Camera Controllers are not initialized"),
      );
    } else {
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  detect();
                },
                icon: const Icon(
                  Icons.search,
                  size: 40,
                )),
            IconButton(
                onPressed: () {
                  controller.stopImageStream().then((value) {
                    setState(() {
                      scaleX = 1.0;
                      scaleY = 1.0;
                      x = 0.5;
                      y = 0.5;
                      w = 0.5;
                      h = 0.5;
                    });
                  });
                },
                icon: const Icon(
                  Icons.restart_alt,
                  size: 40,
                )),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ClipRect(
                  child: Transform.scale(
                    scaleX: scaleX,
                    scaleY: scaleY,
                    // origin: Offset((2 * x + w) / widget.screenW,
                    //     (2 * y - h) / widget.screenH),
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
