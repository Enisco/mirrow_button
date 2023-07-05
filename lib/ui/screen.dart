// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MirrorButtonScreen extends StatefulWidget {
  final List cameras;
  const MirrorButtonScreen({super.key, required this.cameras});

  @override
  State<MirrorButtonScreen> createState() => _MirrorButtonScreenState();
}

class _MirrorButtonScreenState extends State<MirrorButtonScreen> {
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool? _isCameraPermissionGranted;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      enableAudio: false,
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;
    if (status.isGranted) {
      print('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(widget.cameras[1]);
    } else {
      print('Camera Permission: DENIED');
      getPermissionStatus();
    }
  }

  @override
  void initState() {
    super.initState();
    _isCameraPermissionGranted == true ? () {} : getPermissionStatus();
    onNewCameraSelected(widget.cameras[0]);
  }

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

  bool pressed = false;
  void switchPress() {
    setState(() {
      pressed = !pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      // appBar: AppBar(
      //   title: const Text("Mirror Button App"),
      //   backgroundColor: Colors.teal,
      // ),
      body: Center(
        child: GestureDetector(
          onTapUp: (details) => switchPress(),
          onTapDown: (details) => switchPress(),
          child: Card(
            elevation: pressed ? 0 : 12,
            shadowColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(45),
              ),
            ),
            child: SizedBox(
              width: pressed ? 272 : 280,
              height: pressed ? 85 : 90,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: ImageFiltered(
                          imageFilter:
                              ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              // fromHex('#C0C0C0').withOpacity(0.4),
                              Colors.grey.withOpacity(0.6),
                              BlendMode.color,
                            ),
                            child: SizedBox(
                              width: 280,
                              height: 280,
                              child: _isCameraInitialized
                                  ? controller!.buildPreview()
                                  : Container(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Button',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                      ),
                      textScaleFactor: 1.8,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45),
                      color: Colors.yellow.withOpacity(0.05),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

// shaderCallback: (Rect bounds) {
//   return LinearGradient(
//     // colors: [Colors.blue, Colors.red],
//     colors: [
//       fromHex('#C0C0C0'),
//       fromHex('#C0C0C0')
//     ],
//   ).createShader(bounds);
// },
