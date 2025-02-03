import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/annotation_enums.dart';
import '../models/annotation_models.dart';
import '../controllers/controllers.dart';
import '../utils/coordinate_utils.dart';

// AnnotationPainter class
class AnnotationPainter extends CustomPainter {
  final AnnotationController controller;

  AnnotationPainter(
    this.controller,
  );

  // Paint annotations and text on the canvas
  @override
  void paint(Canvas canvas, Size size) {
    for (Annotation annotation in controller.annotations) {
      switch (annotation.runtimeType) {
        case TextAnnotation:
          drawTextAnnotations(canvas, annotation as TextAnnotation, size);
          break;
        case ShapeAnnotation:
          drawShapeAnnotations(canvas, annotation as ShapeAnnotation, size);
          break;
        default:
          throw UnsupportedError(
            'Unknown annotation type: ${annotation.runtimeType}',
          );
      }
    }
  }

  void drawShapeAnnotations(
    Canvas canvas,
    ShapeAnnotation annotation,
    Size visualImageSize,
  ) {
    if (annotation.relativePoints.isEmpty) return;

    final Paint paint = Paint()
      ..color = annotation.color
      ..strokeWidth = annotation.strokeWidth
      ..style = PaintingStyle.stroke;

    List<Offset> visualPoints = annotation.relativePoints
        .map((point) => convertToVisualPosition(
              point: point,
              originalImageSize: controller.originalImageSize!,
              visualSize: visualImageSize,
            ))
        .toList();

    switch (annotation.annotationType) {
      case AnnotationType.line:
        for (var index = 0; index < visualPoints.length - 1; index++) {
          canvas.drawLine(
            visualPoints[index],
            visualPoints[index + 1],
            paint,
          );
        }
        break;

      case AnnotationType.rectangle:
        final rect = Rect.fromPoints(
          visualPoints.first,
          visualPoints.last,
        );
        canvas.drawRect(rect, paint);
        break;

      case AnnotationType.oval:
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
  void drawTextAnnotations(
    Canvas canvas,
    TextAnnotation annotation,
    Size visualImageSize,
  ) {
    final textSpan = TextSpan(
      text: annotation.text,
      style: TextStyle(
        color: annotation.color,
        fontSize: annotation.relativeFontSize * controller.originalImageSize!.height,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    log(
      'renderFontSize: ${controller.fontSize * controller.originalImageSize!.height}', 
      name: 'AnnotationWidget',
    );

    textPainter.layout();

    final point = Offset(
      annotation.relativePosition.dx - textPainter.width / 2,
      annotation.relativePosition.dy - textPainter.height / 2,
    );

    final textPosition = convertToVisualPosition(
      point: point,
      originalImageSize: controller.originalImageSize!,
      visualSize: visualImageSize,
    );

    textPainter.paint(canvas, textPosition);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
