// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mirrow_button/mirror_button_app.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    print(cameras);
  } on CameraException catch (e) {
    print('Error getting list of cameras: $e');
  }
  runApp(MirrorButtonApp(
    cameras: cameras,
  ));
}
