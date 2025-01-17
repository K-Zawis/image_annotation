import 'package:flutter/material.dart';

import 'annotation_enums.dart';
import 'annotation_models.dart';
import 'annotation_controller.dart';

// AnnotationPainter class
class AnnotationPainter extends CustomPainter {
  final ImageAnnotationController controller;

  AnnotationPainter(
    this.controller,
  );

  // Paint annotations and text on the canvas
  @override
  void paint(Canvas canvas, Size size) {
    for (Annotation annotation in controller.annotations) {
      switch (annotation.runtimeType) {
        case TextAnnotation:
          drawTextAnnotations(canvas, annotation as TextAnnotation);
          break;
        case ShapeAnnotation:
          drawShapeAnnotations(canvas, annotation as ShapeAnnotation);
          break;
        default:
          throw UnsupportedError(
            'Unknown annotation type: ${annotation.runtimeType}',
          );
      }
    }
  }

  // Convert relative points to visual coordinates based on the controller's size
  Offset convertToVisualPosition(Offset point, Size originalSize, Size visualSize) {
    double dx = point.dx * (visualSize.width / originalSize.width);
    double dy = point.dy * (visualSize.height / originalSize.height);
    return Offset(dx, dy);
  }

  void drawShapeAnnotations(Canvas canvas, ShapeAnnotation annotation) {
    if (annotation.relativePoints.isEmpty) return;

    final Paint paint = Paint()
      ..color = annotation.color
      ..strokeWidth = annotation.strokeWidth
      ..style = PaintingStyle.stroke;

    List<Offset> visualPoints = annotation.relativePoints
        .map((point) => convertToVisualPosition(
              point,
              controller.originalImageSize,
              controller.visualImageSize,
            ))
        .toList();

    switch (annotation.annotationType) {
      case AnnotationOption.line:
        for (var index = 0; index < visualPoints.length - 1; index++) {
          canvas.drawLine(
            visualPoints[index],
            visualPoints[index + 1],
            paint,
          );
        }
        break;

      case AnnotationOption.rectangle:
        final rect = Rect.fromPoints(
          visualPoints.first,
          visualPoints.last,
        );
        canvas.drawRect(rect, paint);
        break;

      case AnnotationOption.oval:
        final oval = Rect.fromPoints(
          visualPoints.first,
          visualPoints.last,
        );
        canvas.drawOval(oval, paint);
        break;

      default:
        break;
    }
  }

  // Draw text annotations on the canvas
  void drawTextAnnotations(Canvas canvas, TextAnnotation annotation) {
    final textSpan = TextSpan(
      text: annotation.text,
      style: TextStyle(
        color: annotation.color,
        fontSize: annotation.fontSize,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textPosition = Offset(
      annotation.position.dx - textPainter.width / 2,
      annotation.position.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textPosition);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
