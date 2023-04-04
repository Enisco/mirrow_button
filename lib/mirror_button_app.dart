import 'package:flutter/material.dart';
import 'package:mirrow_button/ui/screen.dart';

class MirrorButtonApp extends StatefulWidget {
  final List cameras;
  const MirrorButtonApp({super.key, required this.cameras});

  @override
  State<MirrorButtonApp> createState() => _MirrorButtonAppState();
}

class _MirrorButtonAppState extends State<MirrorButtonApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirror Button App',
      debugShowCheckedModeBanner: false,
      home: MirrorButtonScreen(
        cameras: widget.cameras,
      ),
    );
  }
}
