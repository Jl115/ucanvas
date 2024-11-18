import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Note {
  String id;
  String text;
  Offset position;
  Uint8List? drawingData;

  Note({
    required this.id,
    required this.text,
    required this.position,
    this.drawingData,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'position': {'dx': position.dx, 'dy': position.dy},
        'drawingData': drawingData != null ? base64Encode(drawingData!) : null,
      };

  static Note fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        text: json['text'],
        position: Offset(json['position']['dx'], json['position']['dy']),
        drawingData: json['drawingData'] != null
            ? base64Decode(json['drawingData'])
            : null,
      );
}
