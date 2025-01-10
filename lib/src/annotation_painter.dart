import 'package:flutter/material.dart';

import 'annotation_option.dart';
import 'text_annotation.dart';

// AnnotationPainter class
class AnnotationPainter extends CustomPainter {
  final List<List<Offset>> annotations;
  final List<TextAnnotation> textAnnotations;
  final AnnotationOption annotationType;

  AnnotationPainter(
    this.annotations,
    this.textAnnotations,
    this.annotationType,
  );

  // Paint annotations and text on the canvas
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    drawShapeAnnotations(canvas, paint);
    drawTextAnnotations(canvas);
  }

  void drawShapeAnnotations(Canvas canvas, Paint paint) {
    for (List<Offset> annotation in annotations) {
      if (annotation.isEmpty) continue;

      switch (annotationType) {
        case AnnotationOption.line:
          for (var index = 0; index < annotation.length - 1; index++) {
            canvas.drawLine(annotation[index], annotation[index + 1], paint);
          }
          break;

        case AnnotationOption.rectangle:
          final rect = Rect.fromPoints(annotation.first, annotation.last);
          canvas.drawRect(rect, paint);
          break;

        case AnnotationOption.oval:
          final oval = Rect.fromPoints(annotation.first, annotation.last);
          canvas.drawRect(oval, paint);
          break;

        default:
          break;
      }
    }
  }

  // Draw text annotations on the canvas
  void drawTextAnnotations(Canvas canvas) {
    for (TextAnnotation annotation in textAnnotations) {
      final textSpan = TextSpan(
        text: annotation.text,
        style: TextStyle(
          color: annotation.textColor,
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
