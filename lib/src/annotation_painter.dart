import 'package:flutter/material.dart';

import 'annotation_option.dart';
import 'annotation_models.dart';

// AnnotationPainter class
class AnnotationPainter extends CustomPainter {
  final List<Annotation> annotations;

  AnnotationPainter(
    this.annotations,
  );

  // Paint annotations and text on the canvas
  @override
  void paint(Canvas canvas, Size size) {
    for (Annotation annotation in annotations) {
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

  void drawShapeAnnotations(Canvas canvas, ShapeAnnotation annotation) {
    if (annotation.points.isEmpty) return;

    final Paint paint = Paint()
      ..color = annotation.color
      ..strokeWidth = annotation.strokeWidth
      ..style = PaintingStyle.stroke;

    switch (annotation.annotationType) {
      case AnnotationOption.line:
        for (var index = 0; index < annotation.points.length - 1; index++) {
          canvas.drawLine(
            annotation.points[index],
            annotation.points[index + 1],
            paint,
          );
        }
        break;

      case AnnotationOption.rectangle:
        final rect = Rect.fromPoints(
          annotation.points.first,
          annotation.points.last,
        );
        canvas.drawRect(rect, paint);
        break;

      case AnnotationOption.oval:
        final oval = Rect.fromPoints(
          annotation.points.first,
          annotation.points.last,
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
