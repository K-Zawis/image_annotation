import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'annotation.module.dart';
import 'annotation_enums.module.dart';

/// Represents a shape annotation, which consists of a series of normalized points,
/// a stroke width, and a type that defines the shape.
///
/// This class is used to store and manage points for shapes like lines, rectangles,
/// and ovals.
///
/// @see
/// [Annotation]
class ShapeAnnotation extends Annotation {
  final Paint paint;

  /// The list of normalized points.
  ///
  /// These points define the shape's outline or structure.
  ///
  /// Values should be between `0` and `1`.
  final List<Offset> _normalizedPoints;

  /// The width of the stroke used to draw the shape.
  ///
  /// Defaults to `2.0` if not explicitly provided.
  final double strokeWidth;

  /// Creates a [ShapeAnnotation] instance.
  ///
  /// - [annotationType] : The [AnnotationType] of this shape.
  /// - [strokeWidth] : The width of the stroke used to draw the shape.
  ///   Defaults to `2.0`.
  /// - [color] : The colour of the annotation. Defaults to [Colors.red].
  ShapeAnnotation(
    AnnotationType annotationType, {
    this.strokeWidth = 2.0, // TODO: normalize this value
    Color color = Colors.red,
  })  : assert(strokeWidth > 0, 'strokeWidth must be greater than 0.'),
        _normalizedPoints = [],
        paint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
        super(annotationType, color: color);

  /// Provides an unmodifiable view of the normalized points of the shape.
  List<Offset> get normalizedPoints => List.unmodifiable(_normalizedPoints);

  /// Retrieves the first point in the list of normalized points, if it exists.
  ///
  /// Returns `null` if the list is empty.
  Offset? get firstNormalizedPoint => _normalizedPoints.firstOrNull;

  /// Retrieves the last point in the list of normalized points, if it exists.
  ///
  /// Returns `null` if the list is empty.
  Offset? get lastNormalizedPoint => _normalizedPoints.lastOrNull;

  /// Adds a new point to the list of normalized points.
  ///
  /// - [point]: The point to be added, which should be normalized.
  void add(Offset point) {
    assert(point.dx >= 0 && point.dx <= 1, 'X coordinate is not normalized.');
    assert(point.dy >= 0 && point.dy <= 1, 'Y coordinate is not normalized.');
    _normalizedPoints.add(point);
  }

  @override
  void render(Canvas canvas, Size size) {
    if (_normalizedPoints.isEmpty) return;

    List<Offset> visualPoints = _normalizedPoints
        .map((point) => convertToRenderPosition(
              relativePoint: point,
              visualImageSize: size,
            ))
        .toList();

    switch (annotationType) {
      case AnnotationType.line:
      case AnnotationType.polyline:
        if (visualPoints.length == 1) {
          canvas.drawPoints(PointMode.points, visualPoints, paint);
        } else {
          canvas.drawPoints(PointMode.polygon, visualPoints, paint);
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

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln("ShapeAnnotation(")
      ..writeln("  annotationType: ${annotationType.toString()},")
      ..writeln("  strokeWidth: $strokeWidth,")
      ..writeln("  color: $color,");

    if (annotationType == AnnotationType.line ||
        annotationType == AnnotationType.polyline) {
      buffer.writeln("  normalizedPoints: $_normalizedPoints,");
    } else {
      buffer.writeln("  firstNormalizedPoint: $firstNormalizedPoint,");
      buffer.writeln("  lastNormalizedPoint: $lastNormalizedPoint,");
    }

    buffer.write(")");
    return buffer.toString();
  }
}
