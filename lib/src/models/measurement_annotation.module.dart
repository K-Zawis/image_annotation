import 'package:flutter/material.dart';

import '../../image_annotation.dart' show AnnotationType, ShapeAnnotation;

class MeasurementAnnotation extends ShapeAnnotation {
  MeasurementAnnotation({
    double strokeWidth = 2.0,
    Color color = Colors.red,
    List<Offset>? points,
  }) : super(
          AnnotationType.polyline,
          strokeWidth: strokeWidth,
          color: color,
          points: points,
        );

  @override
  void add(Offset point) {
    if (normalizedPoints.length == 2) return;
    
    super.add(point);
  }
}
