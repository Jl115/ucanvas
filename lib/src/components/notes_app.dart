import 'package:flutter/material.dart';
import 'draggable_note.dart';

class NotesApp extends StatefulWidget {
  const NotesApp({Key? key}) : super(key: key);

  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  final List<Map<String, dynamic>> notes = [];

  void _addNote() {
    setState(() {
      notes.add({
        'id': DateTime.now().toString(),
        'text': 'New Note',
        'position': Offset(100, 100),
        'drawingData': null,
      });
    });
  }

  void _updateNotePosition(String id, Offset position) {
    setState(() {
      final note = notes.firstWhere((note) => note['id'] == id);
      note['position'] = position;
    });
  }

  void _updateNoteText(String id, String text) {
    setState(() {
      final note = notes.firstWhere((note) => note['id'] == id);
      note['text'] = text;
    });
  }

  void _updateNoteDrawing(String id, List<Map<String, dynamic>> drawingData) {
    setState(() {
      final note = notes.firstWhere((note) => note['id'] == id);
      note['drawingData'] = drawingData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNote,
          ),
        ],
      ),
      body: Stack(
        children: notes.map((note) {
          return DraggableNote(
            id: note['id'],
            text: note['text'],
            position: note['position'],
            drawingData: note['drawingData'],
            onPositionChanged: _updateNotePosition,
            onTextChanged: _updateNoteText,
            onDrawingChanged: _updateNoteDrawing,
          );
        }).toList(),
      ),
    );
  }
}
