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
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Mirror Button App"),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Card(
            elevation: 15,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(60),
              ),
            ),
            child: SizedBox(
              width: 280,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(60)),
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: ImageFiltered(
                          imageFilter:
                              ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.grey.withOpacity(0.6), BlendMode.color),
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(60),
                                ),
                              ),
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
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                          letterSpacing: 1.2),
                      textScaleFactor: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
