import 'package:flutter/material.dart';
import 'annotation_option.dart';

abstract class Annotation {
  Color color;

  Annotation(this.color);
}

class TextAnnotation extends Annotation {
  final Offset position;
  final String text;
  double _fontSize;

  TextAnnotation({
    required this.position,
    required this.text,
    double? fontSize,
    Color textColor = Colors.black,
  })  : _fontSize = fontSize ?? 16.0,
        super(textColor);

  double get fontSize => _fontSize;

  set fontSize(double newFontSize) {
    if (newFontSize <= 0) return;

    _fontSize = newFontSize;
  }
}

class ShapeAnnotation extends Annotation {
  final List<Offset> _points;
  double _strokeWidth;
  AnnotationOption annotationType;

  ShapeAnnotation(
    this.annotationType, {
    double? strokeWidth,
    Color color = Colors.red,
  })  : _points = [],
        _strokeWidth = strokeWidth ?? 2.0,
        super(color);

  List<Offset> get points => List.unmodifiable(_points);
  double get strokeWidth => _strokeWidth;

  set strokeWidth(double newWidth) {
    if (newWidth <= 0) return;

    _strokeWidth = newWidth;
  }

  void add(Offset point) {
    _points.add(point);
  }
}
