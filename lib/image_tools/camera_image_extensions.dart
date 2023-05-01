import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:receipt_parser/image_tools/image_data.dart';

extension CameraImageConversion on CameraImage {
  Pointer<ImageData> newImageDataPointer(Arena arena) {
    Uint8List? buffer;
    print(format.group);
    if (format.group == ImageFormatGroup.yuv420) {
      print("Its a yuv");
      print(planes.length);
      print("Plane 0");
      print(planes[0].bytes.length);
      print(planes[0].bytes.length / width);
      print(planes[0].bytes.length / height);

      print("Plane 1");
      print(planes[1].bytes.length);
      print(planes[1].bytes.length / width);
      print(planes[1].bytes.length / height);

      print("Plane 2");
      print(planes[2].bytes.length);
      print(planes[2].bytes.length / width);
      print(planes[2].bytes.length / height);
      print(width);
      print(height);
      buffer = _bufferFromYUV();
    }

    if (format.group == ImageFormatGroup.bgra8888) {
      buffer = planes[0].bytes;
    }

    if (buffer == null) {
      throw FormatException("ImageFormat ${format.group} is not supported");
    }

    final bufferPtr = arena<Uint8>(buffer.lengthInBytes);
    Uint8List bytes = bufferPtr.asTypedList(buffer.lengthInBytes);
    bytes.setAll(0, buffer);


    final imageDataPtr = arena<ImageData>();
    imageDataPtr.ref.bytes = bufferPtr;
    imageDataPtr.ref.size = buffer.lengthInBytes;
    imageDataPtr.ref.width = width;
    imageDataPtr.ref.height = height;
    imageDataPtr.ref.isYUV = (format.group == ImageFormatGroup.yuv420) ? 1 : 0;
    return imageDataPtr;
  }

  int calculateBufferSize(Uint8List yBuffer, Uint8List? uBuffer, Uint8List? vBuffer) {
    final ySize = planes[0].bytes.lengthInBytes; // OR LENGTH IN BYTES?
    if (Platform.isAndroid) {
      final uSize = planes[1].bytes.lengthInBytes;
      final vSize = planes[2].bytes.lengthInBytes;
      return ySize + uSize + vSize;
    }
    return ySize;
  }

  Uint8List _bufferFromYUV() {
    var yBuffer = planes[0].bytes;

    if (planes.length == 1) {
      final bufferSize = width * height;
      yBuffer = Uint8List.view(yBuffer.buffer).sublist(0, bufferSize);
    }
    return yBuffer;
  }
}

