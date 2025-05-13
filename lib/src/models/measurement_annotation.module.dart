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
      const arrowLength = 10.0;
      const tickLength = 6.0;

      // Draw | at a point, perpendicular to the line
      void drawBar(Offset point, double angle) {
        final perpAngle = angle + pi / 2;

        final offset1 = point + Offset.fromDirection(perpAngle, tickLength / 2);
        final offset2 = point - Offset.fromDirection(perpAngle, tickLength / 2);

        canvas.drawLine(offset1, offset2, paint);
      }

      // Draw arrowhead at a point pointing along 'angle'
      void drawArrow(Offset center, double angle) {
        final arrowAngle1 = angle + pi / 6;
        final arrowAngle2 = angle - pi / 6;

        final arrowP1 = center + Offset.fromDirection(arrowAngle1, arrowLength);
        final arrowP2 = center + Offset.fromDirection(arrowAngle2, arrowLength);

        canvas.drawLine(center, arrowP1, paint);
        canvas.drawLine(center, arrowP2, paint);

        // Also draw the vertical bar "|"
        drawBar(center, angle);
      }

      // Draw at both ends
      drawArrow(visualPoints.first, (visualPoints.last - visualPoints.first).direction);
      drawArrow(visualPoints.last, (visualPoints.first - visualPoints.last).direction);
    }
  }
}
