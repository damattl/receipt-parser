import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:receipt_parser/image_tools/image_data.dart';

class C_Uint8List extends Struct {
  @Uint32()
  external int length;

  external Pointer<Uint8> ptr;

  free() {
    malloc.free(ptr);
    ptr = nullptr;
  }
}

extension Uint8ListExtensions on Pointer<ImageData> {
  Uint8List toUint8List() {
    final cBytes = ref.bytes.asTypedList(ref.size);
    return Uint8List.fromList(cBytes);
  }
}

class C_Point extends Struct {
  @Int32()
  external int x;
  @Int32()
  external int y;
}

class C_PointList extends Struct {
  @Uint32()
  external int length;

  external Pointer<C_Point> ptr;

  free() {
    malloc.free(ptr);
    ptr = nullptr;
  }
}

extension PointListExtensions on Pointer<C_Point> {
  List<Point> toList() {
    final list = <Point>[];
    for (var i = 0; i < 4; i++) {
      final point = elementAt(i).ref;

      list.add(Point(point.x, point.y));
    }
    return list;
  }
}
