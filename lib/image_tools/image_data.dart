import 'dart:ffi';

class ImageData extends Struct {
  @Int32()
  external int width;

  @Int32()
  external int height;

  external Pointer<Uint8> bytes;

  @Uint32()
  external int size;

  @Int32()
  external int rotation;

  @Bool()
  external bool isYUV;
}
