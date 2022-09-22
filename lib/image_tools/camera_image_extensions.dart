import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:receipt_parser/image_tools/image_data.dart';

extension CameraImageConversion on CameraImage {
  Pointer<ImageData> newImageDataPointer() {
    final yBuffer = planes[0].bytes;

    Uint8List? uBuffer;
    Uint8List? vBuffer;

    if (Platform.isAndroid) {
      uBuffer = planes[1].bytes;
      vBuffer = planes[2].bytes;
    }

    final bufferSize = calculateBufferSize(yBuffer, uBuffer, vBuffer);
    final imageBuffer = malloc.allocate<Uint8>(bufferSize);

    Uint8List bytes = imageBuffer.asTypedList(bufferSize);
    bytes.setAll(0, yBuffer);

    if (Platform.isAndroid) {
      bytes.setAll(yBuffer.lengthInBytes, vBuffer!); // OpenCV needs u and v swapped
      bytes.setAll(yBuffer.lengthInBytes + vBuffer.lengthInBytes, uBuffer!);
    }

    final imageDataPtr = malloc<ImageData>();
    imageDataPtr.ref.bytes = imageBuffer;
    imageDataPtr.ref.width = width;
    imageDataPtr.ref.height = height;
    imageDataPtr.ref.isYUV = Platform.isAndroid;


    return imageDataPtr;
  }

  int calculateBufferSize(Uint8List yBuffer, Uint8List? uBuffer, Uint8List? vBuffer) {
    final ySize = planes[0].bytes.lengthInBytes;
    if (Platform.isAndroid) {
      final uSize = planes[1].bytes.lengthInBytes;
      final vSize = planes[2].bytes.lengthInBytes;
      return ySize + uSize + vSize;
    }
    return ySize;
  }
}
