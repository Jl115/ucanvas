import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'dart:ui' as ui;

class DraggableNote extends StatefulWidget {
  final String id;
  final String text;
  final Offset position;
  final List<Map<String, dynamic>>? drawingData;
  final Function(String, Offset) onPositionChanged;
  final Function(String, String) onTextChanged;
  final Function(String, List<Map<String, dynamic>>) onDrawingChanged;

  const DraggableNote({
    Key? key,
    required this.id,
    required this.text,
    required this.position,
    this.drawingData,
    required this.onPositionChanged,
    required this.onTextChanged,
    required this.onDrawingChanged,
  }) : super(key: key);

  @override
  _DraggableNoteState createState() => _DraggableNoteState();
}

class _DraggableNoteState extends State<DraggableNote> {
  late Offset position;
  bool isEditingText = false;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    position = widget.position;
    textController = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
            widget.onPositionChanged(widget.id, position);
          });
        },
        onDoubleTap: _toggleEditMode,
        child: Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isEditingText
              ? TextField(
                  controller: textController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type here...',
                  ),
                  onSubmitted: (value) {
                    _toggleEditMode();
                  },
                  onChanged: (value) {
                    widget.onTextChanged(widget.id, value);
                  },
                )
              : Stack(
                  children: [
                    if (widget.drawingData != null)
                      FutureBuilder<ui.Image>(
                        future: _renderDrawing(widget.drawingData!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return RawImage(image: snapshot.data);
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        widget.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      isEditingText = !isEditingText;
    });
  }

  Future<ui.Image> _renderDrawing(
      List<Map<String, dynamic>> drawingData) async {
    final lines = drawingData.map((data) {
      return SketchLine.fromJson(Map<String, dynamic>.from(data));
    }).toList();

    final notifier = ScribbleNotifier();
    notifier.setSketch(sketch: Sketch(lines: lines));

    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final byteData = await notifier.renderImage(pixelRatio: pixelRatio);
    final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
