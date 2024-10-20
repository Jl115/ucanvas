import 'package:flutter/material.dart';

class CanvasWidget extends StatefulWidget {
  @override
  _CanvasWidgetState createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  final Paint _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2.0
    ..isAntiAlias = true;

  final List<Offset> _points = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          RenderBox referenceBox = context.findRenderObject();
          Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
          _points.add(localPosition);
        });
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: _MyPainter(_points, _paint),
      ),
    );
  }
}

class _MyPainter extends CustomPainter {
  final List<Offset> points;
  final Paint paint;

  _MyPainter(this.points, this.paint);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MyPainter oldDelegate) => true;
}
