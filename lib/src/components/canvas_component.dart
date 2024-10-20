import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ucanvas/src/controller/paint_controller.dart';
import 'package:ucanvas/src/model/shape.dart';

class InfiniteCanvas extends StatefulWidget {
  @override
  _InfiniteCanvasState createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  final TransformationController _transformationController =
      TransformationController();
  List<Shape> _shapes = [];
  ShapeType _currentShapeType = ShapeType.line;
  Offset? _startPoint;
  Offset? _currentDragPoint;

  double gridSize = 20.0;
  bool _isApplePencil = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Offset _snapToGrid(Offset point) {
    return Offset(
      (point.dx / gridSize).round() * gridSize,
      (point.dy / gridSize).round() * gridSize,
    );
  }

  void _startDrawing(Offset startPoint) {
    setState(() {
      _startPoint = _snapToGrid(startPoint);
    });
  }

  void _updateDrawing(Offset newPoint) {
    setState(() {
      _currentDragPoint = _snapToGrid(newPoint);
    });
  }

  void _endDrawing() {
    if (_startPoint != null && _currentDragPoint != null) {
      setState(() {
        _shapes.add(Shape(
          type: _currentShapeType,
          start: _startPoint!,
          end: _currentDragPoint!,
        ));
        _startPoint = null;
        _currentDragPoint = null;
      });
    }
    _isApplePencil = false; // Reset after drawing is complete
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Infinite Canvas"),
        actions: [
          IconButton(
            icon: Icon(Icons.create),
            onPressed: () => setState(() => _currentShapeType = ShapeType.line),
          ),
          IconButton(
            icon: Icon(Icons.circle),
            onPressed: () =>
                setState(() => _currentShapeType = ShapeType.circle),
          ),
          IconButton(
            icon: Icon(Icons.rectangle),
            onPressed: () =>
                setState(() => _currentShapeType = ShapeType.rectangle),
          ),
        ],
      ),
      body: Listener(
        onPointerDown: (event) {
          if (event.kind == PointerDeviceKind.stylus) {
            // Detect Apple Pencil
            _isApplePencil = true;
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            Offset localPosition = renderBox.globalToLocal(event.position);
            Matrix4 inverseMatrix =
                Matrix4.inverted(_transformationController.value);
            Offset transformedPosition =
                MatrixUtils.transformPoint(inverseMatrix, localPosition);
            _startDrawing(transformedPosition);
          }
        },
        child: GestureDetector(
          onPanUpdate: (details) {
            if (_isApplePencil) {
              // Only update if using Apple Pencil
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              Offset localPosition =
                  renderBox.globalToLocal(details.globalPosition);
              Matrix4 inverseMatrix =
                  Matrix4.inverted(_transformationController.value);
              Offset transformedPosition =
                  MatrixUtils.transformPoint(inverseMatrix, localPosition);
              _updateDrawing(transformedPosition);
            }
          },
          onPanEnd: (details) {
            if (_isApplePencil) {
              // Only end if using Apple Pencil
              _endDrawing();
            }
          },
          child: InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: EdgeInsets.all(double.infinity),
            panEnabled: true,
            scaleEnabled: true,
            minScale: 0.1,
            maxScale: 5.0,
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: InfiniteCanvasPainter(
                  shapes: _shapes,
                  currentShapeType: _currentShapeType,
                  start: _startPoint,
                  currentDragPoint: _currentDragPoint,
                  transform: _transformationController.value,
                  gridSize: gridSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
