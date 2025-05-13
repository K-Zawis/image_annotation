import 'dart:math' show pi;
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
      canvas.drawLine(visualPoints.first, visualPoints.last, paint);
      // Direction vector
      const tickLength = 10.0; // Arrow size

      // Function to draw inward-pointing arrow lines at a given point
      void drawTick(Offset center, double angle) {
        final perpendicularAngle1 = angle + pi / 6;
        final perpendicularAngle2 = angle - pi / 6;

        final pLeft = center + Offset.fromDirection(perpendicularAngle1, tickLength);
        final pRight = center + Offset.fromDirection(perpendicularAngle2, tickLength);

        canvas.drawLine(center, pLeft, paint);
        canvas.drawLine(center, pRight, paint);
      }

      // Draw start tick pointing inward
      drawTick(visualPoints.first, (visualPoints.last - visualPoints.first).direction);

      // Draw end tick pointing inward
      drawTick(visualPoints.last, (visualPoints.first - visualPoints.last).direction);
    }
  }
}
