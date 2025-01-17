import 'package:flutter/material.dart';
import 'annotation_enums.dart';

abstract class Annotation {
  final Color color;

  Annotation(this.color);
}

class TextAnnotation extends Annotation {
  final Offset position;
  final String text;
  final double fontSize;

  TextAnnotation({
    required this.position,
    required this.text,
    this.fontSize = 16.0,
    Color textColor = Colors.black,
  }) : super(textColor);
}

class ShapeAnnotation extends Annotation {
  final List<Offset> _points;
  final double strokeWidth;
  final AnnotationOption annotationType;

  ShapeAnnotation(
    this.annotationType, {
    this.strokeWidth = 2.0,
    Color color = Colors.red,
  })  : _points = [],
        super(color);

  List<Offset> get points => List.unmodifiable(_points);
  Offset? get firstPoint => _points.firstOrNull;
  Offset? get lastPoint => _points.lastOrNull;

  void add(Offset point) {
    _points.add(point);
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('ShapeAnnotation(')
      ..writeln('  annotationType: ${annotationType.toString()},')
      ..writeln('  strokeWidth: $strokeWidth,')
      ..writeln('  color: $color,');

    if (annotationType == AnnotationOption.line) {
      buffer.writeln('  points: $_points,');
    } else {
      buffer.writeln('  firstPoint: ${_points.firstOrNull},');
      buffer.writeln('  lastPoint: ${_points.lastOrNull},');
    }

    buffer.write(')');
    return buffer.toString();
  }
}
