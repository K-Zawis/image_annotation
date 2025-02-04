import 'package:flutter/material.dart';

import '../utils/coordinate.utils.dart';
import '../utils/font.utils.dart';
import 'annotation_enums.module.dart';
import 'shape_annotation.module.dart';

/// Represents a detected rectangle annotation with a label and confidence score.
///
/// @see
/// [ShapeAnnotation]
/// [Annotation]
class DetectedAnnotation extends ShapeAnnotation {
  /// The label of the detected annotation (for example: object type).
  final String label;

  /// The confidence score of the detection, between 0.0 and 1.0.
  final double confidenceScore;

  /// The normalized font size.
  ///
  /// Defaults to `0.0`, but when rendered, it should be scaled
  /// according to the image's visual size.
  double normalizedFontSize = 0.0;

  /// Creates a [DetectedAnnotation] instance.
  ///
  /// - [label]: The label of the detected object.
  /// - [confidenceScore]: The confidence score of the detection.
  /// - [points]: A list of [Offset] objects defining the rectangle.
  ///   Relative to the original image size.
  /// - [strokeWidth]: The width of the stroke used to draw the shape.
  /// - [color]: The color of the annotation.
  DetectedAnnotation({
    required this.label,
    required this.confidenceScore,
    required List<Offset> normalizedPoints,
    double strokeWidth = 2.0,
    Color color = Colors.red,
  }) : super(
          AnnotationType.rectangle,
          strokeWidth: strokeWidth,
          color: color,
        ) {
    for (final point in normalizedPoints) {
      assert(point.dx >= 0 && point.dx <= 1, 'X coordinate is not normalized.');
      assert(point.dy >= 0 && point.dy <= 1, 'Y coordinate is not normalized.');
      add(point);
    }
  }

  /// Finds the top-left point from the list of points.
  Offset? get topLeftPoint {
    if (normalizedPoints.isEmpty) return null;

    final minX = normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 < x2 ? x1 : x2,
        );
    final maxY = normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 > y2 ? y1 : y2,
        );

    return Offset(minX, maxY);
  }

  /// Finds the bottom-left point from the list of points.
  Offset? get bottomLeftPoint {
    if (normalizedPoints.isEmpty) return null;

    final minX = normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 < x2 ? x1 : x2,
        );
    final minY = normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 < y2 ? y1 : y2,
        );

    return Offset(minX, minY);
  }

  /// Finds the top-right point from the list of points.
  Offset? get topRightPoint {
    if (normalizedPoints.isEmpty) return null;

    final maxX = normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 > x2 ? x1 : x2,
        );
    final maxY = normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 > y2 ? y1 : y2,
        );

    return Offset(maxX, maxY);
  }

  /// Finds the bottom-right point from the list of points.
  Offset? get bottomRightPoint {
    if (normalizedPoints.isEmpty) return null;

    final maxX = normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 > x2 ? x1 : x2,
        );
    final minY = normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 < y2 ? y1 : y2,
        );

    return Offset(maxX, minY);
  }

  @override
  void render(Canvas canvas, Size size) {
    if (normalizedPoints.isEmpty) return;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    List<Offset> visualPoints = normalizedPoints
        .map((point) => convertToRenderPosition(
              relativePoint: point,
              visualImageSize: size,
            ))
        .toList();

    final rect = Rect.fromPoints(
      visualPoints.first,
      visualPoints.last,
    );
    canvas.drawRect(rect, paint);

    final Paint labelPaint = paint..style = PaintingStyle.fill;
    final labelText = "$label ${confidenceScore.toStringAsFixed(2)}";

    final textSpan = TextSpan(
      text: labelText,
      style: TextStyle(
        color: Colors.white,
        fontSize: convertToRenderFontSize(
          normalizedFontSize: normalizedFontSize,
          visualImageSize: size,
        ),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final Offset topLeftCorner = convertToRenderPosition(
      relativePoint: topLeftPoint!,
      visualImageSize: size,
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
  String toString() {
    final buffer = StringBuffer()
      ..writeln('DetectedAnnotation(')
      ..writeln('  annotationType: $annotationType,')
      ..writeln('  label: $label,')
      ..writeln('  confidenceScore: $confidenceScore,')
      ..writeln('  strokeWidth: $strokeWidth,')
      ..writeln('  color: $color,')
      ..writeln('  firstNormalizedPoint: $firstNormalizedPoint,')
      ..writeln('  lastNormalizedPoint: $lastNormalizedPoint,')
      ..write(')');
    return buffer.toString();
  }
}
