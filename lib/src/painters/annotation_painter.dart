import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';
import '../utils/utils.dart';

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
        case DetectedAnnotation:
          drawDetectedAnnotations(
              canvas, annotation as DetectedAnnotation, size);
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
    if (annotation.normalizedPoints.isEmpty) return;

    final Paint paint = Paint()
      ..color = annotation.color
      ..strokeWidth = annotation.strokeWidth
      ..style = PaintingStyle.stroke;

    List<Offset> visualPoints = annotation.normalizedPoints
        .map((point) => convertToRenderPosition(
              relativePoint: point,
              visualImageSize: visualImageSize,
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

  void drawTextAnnotations(
    Canvas canvas,
    TextAnnotation annotation,
    Size visualImageSize,
  ) {
    final textSpan = TextSpan(
      text: annotation.text,
      style: TextStyle(
        color: annotation.color,
        fontSize: convertToRenderFontSize(
          normalizedFontSize: annotation.normalizedFontSize,
          originalImageSize: controller.originalImageSize!,
          visualImageSize: visualImageSize,
        ),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final Offset renderPosition = convertToRenderPosition(
      relativePoint: annotation.normalizedPosition,
      visualImageSize: visualImageSize,
    );

    final textPosition = Offset(
      renderPosition.dx - textPainter.width / 2,
      renderPosition.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textPosition);
  }

  void drawDetectedAnnotations(
    Canvas canvas,
    DetectedAnnotation annotation,
    Size visualImageSize,
  ) {
    if (annotation.normalizedPoints.isEmpty) return;

    final Paint paint = Paint()
      ..color = annotation.color
      ..strokeWidth = annotation.strokeWidth
      ..style = PaintingStyle.stroke;

    List<Offset> visualPoints = annotation.normalizedPoints
        .map((point) => convertToRenderPosition(
              relativePoint: point,
              visualImageSize: visualImageSize,
            ))
        .toList();

    final rect = Rect.fromPoints(
      visualPoints.first,
      visualPoints.last,
    );
    canvas.drawRect(rect, paint);

    final Paint labelPaint = paint..style = PaintingStyle.fill;
    final labelText =
        "${annotation.label} ${annotation.confidenceScore.toStringAsFixed(2)}";

    final textSpan = TextSpan(
      text: labelText,
      style: TextStyle(
        color: Colors.white,
        fontSize: convertToRenderFontSize(
          normalizedFontSize: convertToNormalizedFontSize(
            fontSize: controller.fontSize,
            originalImageSize: controller.originalImageSize!,
            visualImageSize: visualImageSize,
          ),
          originalImageSize: controller.originalImageSize!,
          visualImageSize: visualImageSize,
        ),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final Offset topLeftCorner = convertToRenderPosition(
      relativePoint: annotation.topLeftPoint!,
      visualImageSize: visualImageSize,
    );

    final labelRect = Rect.fromPoints(
      topLeftCorner,
      Offset(
        topLeftCorner.dx + textPainter.width,
        topLeftCorner.dy - textPainter.height,
      ),
    );

    canvas.drawRect(labelRect, labelPaint);

    textPainter.paint(
      canvas,
      Offset(
        topLeftCorner.dx,
        topLeftCorner.dy - textPainter.height,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
