import 'package:flutter/material.dart';
import 'package:ucanvas/src/model/shape.dart';

class InfiniteCanvasPainter extends CustomPainter {
  final List<Shape> shapes;
  final ShapeType currentShapeType;
  final Offset? start;
  final Offset? currentDragPoint;
  final Matrix4 transform;
  final double gridSize;

  InfiniteCanvasPainter({
    required this.shapes,
    required this.currentShapeType,
    this.start,
    this.currentDragPoint,
    required this.transform,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.transform(transform.storage);

    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0 / transform.getMaxScaleOnAxis();

    // Draw grid
    for (double x = 0; x < size.width; x += gridSize) {
      for (double y = 0; y < size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 1 / transform.getMaxScaleOnAxis(),
            paint..color = Colors.grey);
      }
    }

    // Draw shapes
    paint.color = Colors.red;
    for (var shape in shapes) {
      _drawShape(canvas, shape.start, shape.end, shape.type, paint);
    }

    // Draw current shape while dragging
    if (start != null && currentDragPoint != null) {
      _drawShape(canvas, start!, currentDragPoint!, currentShapeType, paint);
    }
  }

  void _drawShape(
      Canvas canvas, Offset start, Offset end, ShapeType type, Paint paint) {
    switch (type) {
      case ShapeType.line:
        canvas.drawLine(start, end, paint);
        break;
      case ShapeType.circle:
        double radius = (end - start).distance / 2;
        Offset center =
            Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
        canvas.drawCircle(center, radius, paint);
        break;
      case ShapeType.rectangle:
        Rect rect = Rect.fromPoints(start, end);
        canvas.drawRect(rect, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant InfiniteCanvasPainter oldDelegate) {
    return oldDelegate.shapes != shapes ||
        oldDelegate.currentShapeType != currentShapeType ||
        oldDelegate.start != start ||
        oldDelegate.currentDragPoint != currentDragPoint ||
        oldDelegate.gridSize != gridSize;
  }
}
