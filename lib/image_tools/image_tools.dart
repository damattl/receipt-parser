import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:receipt_parser/image_tools/c_structs.dart';
import 'package:receipt_parser/image_tools/camera_image_extensions.dart';
import 'package:receipt_parser/image_tools/image_data.dart';

typedef NativeTransformImageFunction = Pointer<C_Uint8List> Function(Pointer<ImageData>);
typedef NativeFindDocumentBoundariesInImageFunction = Pointer<C_PointList> Function(Pointer<ImageData>);

class ImageToolsFFI {
  static late DynamicLibrary nativeImageToolsLib;
  static late NativeTransformImageFunction _transformImage;
  static late NativeFindDocumentBoundariesInImageFunction _findDocumentBoundariesInImage;

  static bool initialize() {
    nativeImageToolsLib = Platform.isIOS ? DynamicLibrary.process() : (DynamicLibrary.open('libimage_tools.so'));

    final transformImagePtr = nativeImageToolsLib
        .lookup<NativeFunction<NativeTransformImageFunction>>('transformImage');
    _transformImage = transformImagePtr
        .asFunction<NativeTransformImageFunction>();

    final findDocumentBoundariesInImagePtr = nativeImageToolsLib
        .lookup<NativeFunction<NativeFindDocumentBoundariesInImageFunction>>('findDocumentBoundariesInImage');
    _findDocumentBoundariesInImage = findDocumentBoundariesInImagePtr
        .asFunction<NativeFindDocumentBoundariesInImageFunction>();

    return true;
  }


  static Uint8List transformImage(CameraImage image) {
    final imageDataPtr = image.newImageDataPointer();

    final transformedImageDataPtr = _transformImage(imageDataPtr);
    final bytes = transformedImageDataPtr.toUint8List();

    imageDataPtr.ref.free(); // TODO: Don't know if necessary, but its safer
    malloc.free(imageDataPtr); // Free the underlying array
    transformedImageDataPtr.ref.free(); // Free the underlying array -> TODO: Check if this is even mallocated in C Code
    malloc.free(transformedImageDataPtr);

    return bytes;
  }

  static List<Point> findBoundariesInImage(CameraImage image) {
    final imageDataPtr = image.newImageDataPointer();

    final boundariesPtr = _findDocumentBoundariesInImage(imageDataPtr); // TODO: Terminate C output with nullptr
    final boundaries = boundariesPtr.toList();

    boundariesPtr.ref.free();
    malloc.free(boundariesPtr);

    return boundaries;
  }

  // TODO: Add c files to Runner (Xcode)
}

