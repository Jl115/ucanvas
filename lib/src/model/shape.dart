import 'package:flutter/material.dart';

enum ShapeType { line, circle, rectangle }

class Shape {
  final ShapeType type;
  final Offset start;
  final Offset end;

  Shape({required this.type, required this.start, required this.end});
}
