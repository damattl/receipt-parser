import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:receipt_parser/image_tools/image_tools.dart';

void main() {
  test("Simple Image Tools Test", () {
    const libPath = "./native_image_tools/src/cmake-build-release/libimage_tools.dylib";

    ImageToolsFFI.initialize(overrideLib: libPath);
    final image = img.decodeImage(File("./algorithms/images/receipt_2.jpg").readAsBytesSync());
    expect(image != null, true);

    if (image == null) {
      fail("Image can't be null");
    }

    var gray888 = img.grayscale(image);
    final gray8 = img.Image(width: image.width, height: image.height, numChannels: 1);
    for (final pixel in gray888) {
      final color = img.ColorUint8.fromList([(pixel.r/3 + pixel.g/3 + pixel.b/3).toInt()]);
      gray8.setPixel(pixel.x, pixel.y, color);
    }
    
    final buffer = gray8.data?.buffer;
    if (buffer == null) {
      fail("Buffer is empty");
    }

    final arena = Arena();
    final result = ImageToolsFFI.findBoundariesInImageBytes(buffer.asUint8List(), image.width, image.height, 0, arena);

    print(gray8.lengthInBytes / image.width);

    print(image.height);
    print(image.width);
    print(gray8.numChannels);
    print(result);

    arena.releaseAll();
    img.encodeImageFile("./test/receipt_2.jpg", gray8);

  });
}