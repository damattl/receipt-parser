import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:receipt_parser/result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    Key? key,
    required this.camera
  }) : super(key: key);

  final CameraDescription camera;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          }
          else {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ResultScreen(
                imagePath: image.path
              ))
            );
          }
          catch(e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
