import 'dart:ffi';
import 'dart:io';

import 'package:camera/camera.dart';

class ImageData extends Struct {
  @Int32()
  external int width;

  @Int32()
  external int height;

  @Int32()
  external int rotation;

  external Pointer<Uint8> bytes;

  @Bool()
  external bool isYUV;

}

class Point extends Struct {
  @Int32()
  external int x;
  @Int32()
  external int y;
}

class ImageToolsFFI {
  static late DynamicLibrary nativeImageToolsLib;
  static late Function _transformImage;
  static late Function _findDocumentBoundariesInImage;

  static bool initialize() {
    nativeImageToolsLib = Platform.isIOS ? DynamicLibrary.process() : (DynamicLibrary.open('libimage_tools_cpp.so'));

    final transformImagePtr = nativeImageToolsLib
        .lookup<NativeFunction<Pointer<Uint8> Function(Pointer<ImageData>)>>('transformImage');
    _transformImage = transformImagePtr
        .asFunction<Pointer<Uint8> Function(Pointer<ImageData>)>();

    final findDocumentBoundariesInImagePtr = nativeImageToolsLib
        .lookup<NativeFunction<Pointer<Point> Function(Pointer<ImageData>)>>('findDocumentBoundariesInImage');
    _findDocumentBoundariesInImage = findDocumentBoundariesInImagePtr
        .asFunction<Pointer<Point> Function(Pointer<ImageData>)>();

    return true;
  }

  static CameraImage transformImage(CameraImage image) {
    throw UnimplementedError();
  }

  static List<Point> findBoundariesInImage(CameraImage image) {
    throw UnimplementedError();
  }

  // TODO: Add c files to Runner (Xcode)
}

