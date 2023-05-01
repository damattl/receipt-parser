import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
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

typedef Boundaries = List<Point<num>>;

class ImageToolsFFI {
  static late DynamicLibrary nativeImageToolsLib;
  static late TransformImageFunction _transformImage;
  static late FindDocumentBoundariesInImageFunction _findDocumentBoundariesInImage;

  static bool initialize({String? overrideLib}) {
    dev.log(Directory.current.toString());

    nativeImageToolsLib = Platform.isIOS ? DynamicLibrary.process() :
      (DynamicLibrary.open(overrideLib ?? 'libimage_tools.so'));
    dev.log("Loaded");

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
    return using((arena) {
      final imageDataPtr = image.newImageDataPointer(arena);

      _transformImage(imageDataPtr);
      return imageDataPtr.toUint8List();
    });
    // malloc.free(imageDataPtr.ref.bytes);
    // malloc.free(imageDataPtr); // Free the underlying array

    // return bytes;
  }

  static Boundaries findBoundariesInImageBytes(Uint8List buffer, int width, int height, int rotation, Arena arena) {
    final bufferPtr = arena<Uint8>(buffer.lengthInBytes);
    Uint8List bytes = bufferPtr.asTypedList(buffer.lengthInBytes);
    bytes.setAll(0, buffer);
    const isYUV = 1;

    final imageDataPtr = arena<ImageData>();
    imageDataPtr.ref.width = width;
    imageDataPtr.ref.height = height;
    imageDataPtr.ref.size = buffer.lengthInBytes;
    imageDataPtr.ref.rotation = rotation;
    imageDataPtr.ref.isYUV = isYUV; // TODO: for now
    imageDataPtr.ref.bytes = bufferPtr;

    final boundariesPtr = arena<C_Point>(4);

    try {
      _findDocumentBoundariesInImage(imageDataPtr, boundariesPtr);
    } catch(e) {
      print(e);
    }
    final boundaries = boundariesPtr.toList();
    return boundaries;
  }

  static Boundaries findBoundariesInImage(CameraImage image, int rotation, Arena arena) {
    final imageDataPtr = image.newImageDataPointer(arena);
    imageDataPtr.ref.rotation = rotation;

    final boundariesPtr = arena<C_Point>(4);

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

    return boundaries;
  }

  // TODO: Add c files to Runner (Xcode)
}

