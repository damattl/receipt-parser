import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

class C_Uint8List extends Struct {
  @Int32()
  external int size;

  external Pointer<Uint8> ptr;

  free() {
    malloc.free(ptr);
    ptr = nullptr;
  }
}

extension Uint8ListExtensions on Pointer<C_Uint8List> {
  Uint8List toUint8List() {
    final cBytes = ref.ptr.asTypedList(ref.size);
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
  @Int32()
  external int size;

  external Pointer<C_Point> ptr;

  free() {
    malloc.free(ptr);
    ptr = nullptr;
  }
}

extension PointListExtensions on Pointer<C_PointList> {
  List<Point> toList() {
    final list = <Point>[];
    for (var i = 0; i <= ref.size; i++) {
      final point = ref.ptr.elementAt(i).ref;
      list.add(Point(point.x, point.y));
    }
    return list;
  }
}
