import 'dart:ffi';

import 'package:ffi/ffi.dart';

class ImageData extends Struct {
  @Int32()
  external int width;

  @Int32()
  external int height;

  external Pointer<Uint8> bytes;

  @Bool()
  external bool isYUV;

  free() {
    malloc.free(bytes);
    bytes = nullptr;
  }
}
