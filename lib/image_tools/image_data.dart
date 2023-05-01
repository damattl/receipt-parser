import 'dart:ffi' as ffi;

class ImageData extends ffi.Struct {
  @ffi.Int()
  external int width;

  @ffi.Int()
  external int height;

  @ffi.UnsignedLong()
  external int size;

  @ffi.Int()
  external int rotation;

  @ffi.Int()
  external int isYUV;

  external ffi.Pointer<ffi.Uint8> bytes;
}
