import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:receipt_parser/image_tools/image_tools.dart';

class ImageWorker {
  SendPort? _imagePort;
  Isolate? _isolate;
  final _isolateReady = Completer<void>();
  Completer<Boundaries>? _boundariesResult;

  Future<void> get isReady => _isolateReady.future;

  final arena = Arena();

  void dispose() {
    _isolate?.kill();
    _isolate = null;
    arena.releaseAll();
  }

  Future<void> init() async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    errorPort.listen((message) {dev.log(message);});

    receivePort.listen(_handleReceive);

    _isolate = await Isolate.spawn(
        _entryPoint,
        receivePort.sendPort,
        // onError: errorPort.sendPort
    );
  }

  Future<Boundaries?> findImageBoundaries(CameraImage image) async {
    if (_imagePort == null) {
      return null;
    }
    _imagePort?.send(image);

    _boundariesResult = Completer<Boundaries>();
    return _boundariesResult?.future;
  }

  Future<void> _entryPoint(SendPort p) async {
    ImageToolsFFI.initialize();

    final imagePort = ReceivePort();
    p.send(imagePort.sendPort);
    await for (final message in imagePort) {
      dev.log(message.toString());
      assert(message is CameraImage);

      try {
        final result = ImageToolsFFI.findBoundariesInImage(message, 90, arena); // Find a better way to handle rotation;
        dev.log(result.toString());
        arena.releaseAll(reuse: true);
        p.send(result);
      } finally {

      }
    }
  }

  void _handleReceive(dynamic message) {
    if (message is SendPort) {
      _imagePort = message;
      _isolateReady.complete();
      return;
    }
    if (message is List<Point<num>>) {
      _boundariesResult?.complete(message);
      _boundariesResult = null;
      return;
    }

    // TODO: Handle image
    throw UnimplementedError();
  }
}