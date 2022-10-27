import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:receipt_parser/image_tools/image_boundaries_painter.dart';
import 'package:receipt_parser/image_tools/image_tools.dart';
import 'package:receipt_parser/result_screen.dart';
import 'dart:developer' as dev;

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

  bool _canProcess = true;
  bool _isBusy = false;
  int _lastRun = 0;
  int _cameraRotation = 0;
  ImageBoundariesPainter? _boundaryPainter;

  @override
  void initState() {
    super.initState();
    _startLiveFeed();
  }

  Future _startLiveFeed() async {
    _cameraRotation = Platform.isAndroid ? widget.camera.sensorOrientation : 0;
    _controller = CameraController(
        widget.camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888
    );

    _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture.then((_) {
      if (!mounted) {
        return;
      }
      _controller.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller.stopImageStream();
    await _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(
              _controller,
              child: CustomPaint(
                foregroundPainter: _boundaryPainter,
                child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                )
              ),
            );
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
  
  Future _processCameraImage(CameraImage image) async {
    if (!_canProcess) return;
    if (_isBusy || DateTime.now().millisecondsSinceEpoch - _lastRun < 1000) return;
    _isBusy = true;
    final boundaries = ImageToolsFFI.findBoundariesInImage(image, _cameraRotation);
    dev.log(boundaries.toString());
    if (boundaries.length != 4) {
      _isBusy = false;
      return;
    }

    setState(() {
      _boundaryPainter = ImageBoundariesPainter(
          boundaries,
          Size(image.height.toDouble(), image.width.toDouble())
      );
    });
    _lastRun = DateTime.now().millisecondsSinceEpoch;
    _isBusy = false;
  }

  @override
  void dispose() {
    _canProcess = false; // TODO: Dispose ImageTools?
    _stopLiveFeed();
    super.dispose();
  }
}
