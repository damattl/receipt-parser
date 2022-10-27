import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:receipt_parser/image_tools/c_structs.dart';
import 'package:receipt_parser/image_tools/camera_image_extensions.dart';
import 'package:receipt_parser/image_tools/image_data.dart';

typedef NativeTransformImageFunction = Void Function(Pointer<ImageData>);
typedef TransformImageFunction = void Function(Pointer<ImageData>);
typedef NativeFindDocumentBoundariesInImageFunction = Uint32 Function(Pointer<ImageData>, Pointer<C_Point>);
typedef FindDocumentBoundariesInImageFunction = int Function(Pointer<ImageData>, Pointer<C_Point>);

class ImageToolsFFI {
  static late DynamicLibrary nativeImageToolsLib;
  static late TransformImageFunction _transformImage;
  static late FindDocumentBoundariesInImageFunction _findDocumentBoundariesInImage;

  static bool initialize() {
    nativeImageToolsLib = Platform.isIOS ? DynamicLibrary.process() : (DynamicLibrary.open('libimage_tools.so'));

    final transformImagePtr = nativeImageToolsLib
        .lookup<NativeFunction<NativeTransformImageFunction>>('transformImage');
    _transformImage = transformImagePtr
        .asFunction<TransformImageFunction>();

    final findDocumentBoundariesInImagePtr = nativeImageToolsLib
        .lookup<NativeFunction<NativeFindDocumentBoundariesInImageFunction>>('findDocumentBoundariesInImage');
    _findDocumentBoundariesInImage = findDocumentBoundariesInImagePtr
        .asFunction<FindDocumentBoundariesInImageFunction>();

    return true;
  }



  static Uint8List transformImage(CameraImage image) {
    final imageDataPtr = image.newImageDataPointer();

    _transformImage(imageDataPtr);
    final bytes = imageDataPtr.toUint8List();

    malloc.free(imageDataPtr.ref.bytes);
    malloc.free(imageDataPtr); // Free the underlying array

    return bytes;
  }

  static List<Point> findBoundariesInImage(CameraImage image, int rotation) {
    final imageDataPtr = image.newImageDataPointer();
    imageDataPtr.ref.rotation = rotation;
    final boundariesPtr = calloc<C_Point>(4);

    try {
      _findDocumentBoundariesInImage(imageDataPtr, boundariesPtr); // TODO: Terminate C output with nullptr :: still necessary?
    } catch(e) {
      print("image.width: ${image.width}");
      print("image.height: ${image.height}");
      print("image.format.raw : ${image.format.raw}");
      print("image.planes[0].bytesPerRow : ${image.planes[0].bytesPerRow}");
      print(e);
    }







    final boundaries = boundariesPtr.toList();

    malloc.free(imageDataPtr.ref.bytes);
    malloc.free(imageDataPtr);
    malloc.free(boundariesPtr);

    return boundaries;
  }

  // TODO: Add c files to Runner (Xcode)
}

