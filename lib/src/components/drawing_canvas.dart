import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'dart:ui' as ui;

class DrawingCanvas extends StatefulWidget {
  final List<Map<String, dynamic>>? initialDrawingData;
  final Function(List<Map<String, dynamic>>) onSave;

  const DrawingCanvas({Key? key, this.initialDrawingData, required this.onSave})
      : super(key: key);

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late ScribbleNotifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = ScribbleNotifier();

    // Initialize the sketch if initial drawing data is provided
    if (widget.initialDrawingData != null) {
      final lines = widget.initialDrawingData!.map((data) {
        return SketchLine.fromJson(Map<String, dynamic>.from(data));
      }).toList();

      final sketch = Sketch(lines: lines);
      notifier.setSketch(sketch: sketch);
    }
  }

  Future<void> saveDrawing() async {
    // Extract the current lines and serialize to JSON
    final linesData =
        notifier.currentSketch.lines.map((line) => line.toJson()).toList();
    widget.onSave(linesData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: notifier.canUndo ? notifier.undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: notifier.canRedo ? notifier.redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await saveDrawing();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Scribble(
        notifier: notifier,
        drawPen: true,
        drawEraser: true,
      ),
    );
  }
}
