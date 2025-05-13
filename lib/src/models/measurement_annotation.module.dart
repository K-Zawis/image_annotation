import 'dart:ui';

import 'package:flutter/material.dart';

import '../../image_annotation.dart' show AnnotationType, ShapeAnnotation;
import '../utils/utils.dart';

class MeasurementAnnotation extends ShapeAnnotation {
  MeasurementAnnotation({
    double strokeWidth = 2.0,
    Color color = Colors.red,
    List<Offset>? points,
  }) : super(
          AnnotationType.measurement,
          strokeWidth: strokeWidth,
          color: color,
          points: points,
        );

  @override
  void add(Offset point) {
    if (normalizedPoints.length == 2) return;

    super.add(point);
  }

  @override
  void render(Canvas canvas, Size size) {
    if (normalizedPoints.isEmpty) return;

    List<Offset> visualPoints = normalizedPoints.map((point) => point.toAbsolute(size)).toList();

    if (visualPoints.length == 1) {
      canvas.drawPoints(PointMode.points, visualPoints, paint);
    } else {
      canvas.drawPoints(PointMode.polygon, visualPoints, paint);
    }
  }
}
