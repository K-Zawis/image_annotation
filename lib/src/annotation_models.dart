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

  // TODO: add relative position to text as well!
}

class ShapeAnnotation extends Annotation {
  final List<Offset> _relativePoints;
  final double strokeWidth;
  final AnnotationType annotationType;

  ShapeAnnotation(
    this.annotationType, {
    this.strokeWidth = 2.0,
    Color color = Colors.red,
  })  : _relativePoints = [],
        super(color);

  List<Offset> get relativePoints => List.unmodifiable(_relativePoints);
  Offset? get firstRelativePoint => _relativePoints.firstOrNull;
  Offset? get lastRelativePoint => _relativePoints.lastOrNull;

  void add(Offset point) {
    _relativePoints.add(point);
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('ShapeAnnotation(')
      ..writeln('  annotationType: ${annotationType.toString()},')
      ..writeln('  strokeWidth: $strokeWidth,')
      ..writeln('  color: $color,');

    if (annotationType == AnnotationType.line) {
      buffer.writeln('  relativePoints: $relativePoints,');
    } else {
      buffer.writeln('  firstRelativePoint: $firstRelativePoint,');
      buffer.writeln('  lastRelativePoint: $lastRelativePoint,');
    }

    buffer.write(')');
    return buffer.toString();
  }
}
