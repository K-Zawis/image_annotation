import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/coordinate.utils.dart';
import 'annotation_enums.module.dart';
import 'shape_annotation.module.dart';

/// Represents a polygon annotation, which is a closed shape formed by a series of points.
///
/// A polygon must have at least four points, with the first and last points being identical
/// to ensure closure. This class extends [ShapeAnnotation] and provides additional
/// validation methods specific to polygons.
///
/// @see
/// [ShapeAnnotation]
/// [Annotation]
class PolygonAnnotation extends ShapeAnnotation {
  /// Creates a [PolygonAnnotation] instance.
  ///
  /// - [strokeWidth] : The width of the stroke used to draw the polygon.
  ///   Defaults to `2.0`.
  /// - [color] : The color of the annotation. Defaults to [Colors.red].
  PolygonAnnotation({
    double strokeWidth = 2.0,
    Color color = Colors.red,
  }) : super(
          AnnotationType.polygon,
          strokeWidth: strokeWidth,
          color: color,
        );

  /// Determines whether the polygon is valid.
  ///
  /// A valid polygon must:
  /// - Contain at least four points.
  /// - Be a closed ring (the first and last points must match).
  /// - Not contain any self-intersections (spikes or punctures).
  ///
  /// Returns `true` if the polygon meets all these conditions, otherwise `false`.
  bool get isValid {
    final List<Offset> points = normalizedPoints;

    if (points.length < 4) return false;
    if (!_isRingClosed()) return false;
    if (_hasSpikesOrPunctures(points)) return false;

    return true;
  }

  /// Closes the polygon by adding the first point to the end of the list.
  ///
  /// This ensures that the polygon is properly closed, forming a continuous shape.
  void close() {
    if (firstNormalizedPoint != null) add(firstNormalizedPoint!);
  }

  /// Checks whether the polygon forms a closed ring.
  ///
  /// A polygon is considered closed if its first and last points are the same.
  ///
  /// Returns `true` if the ring is closed, otherwise `false`.
  bool _isRingClosed() {
    if (firstNormalizedPoint == null) return false;

    return firstNormalizedPoint == lastNormalizedPoint;
  }

  /// Detects whether the polygon contains self-intersections (spikes or punctures).
  ///
  /// This method iterates through the polygon's edges to check if any two non-adjacent
  /// edges intersect, which would indicate an invalid shape.
  ///
  /// Returns `true` if the polygon has self-intersections, otherwise `false`.
  bool _hasSpikesOrPunctures(List<Offset> points) {
    for (int i = 0; i < points.length - 2; i++) {
      for (int j = i + 2; j < points.length - 1; j++) {
        if (_linesIntersect(
          points[i],
          points[i + 1],
          points[j],
          points[j + 1],
        )) {
          return true;
        }
      }
    }
    return false;
  }

  /// Checks whether two line segments (A-B and C-D) intersect.
  ///
  /// This method uses the concept of the **cross product** to determine the relative
  /// orientation of two vectors. For each of the two line segments, it calculates
  /// the cross products between their direction vectors and the vectors formed by
  /// the endpoints of the other segment. If the cross products have opposite signs,
  /// this indicates that the line segments intersect.
  ///
  /// - [a], [b] : The endpoints of the first line segment.
  /// - [c], [d] : The endpoints of the second line segment.
  ///
  /// Returns `true` if the segments intersect, otherwise `false`.
  bool _linesIntersect(Offset a, Offset b, Offset c, Offset d) {
    double crossProduct(Offset v1, Offset v2) => v1.dx * v2.dy - v1.dy * v2.dx;

    Offset ab = Offset(b.dx - a.dx, b.dy - a.dy);
    Offset ac = Offset(c.dx - a.dx, c.dy - a.dy);
    Offset ad = Offset(d.dx - a.dx, d.dy - a.dy);
    Offset cd = Offset(d.dx - c.dx, d.dy - c.dy);
    Offset ca = Offset(a.dx - c.dx, a.dy - c.dy);
    Offset cb = Offset(b.dx - c.dx, b.dy - c.dy);

    double cross1 = crossProduct(ab, ac);
    double cross2 = crossProduct(ab, ad);
    double cross3 = crossProduct(cd, ca);
    double cross4 = crossProduct(cd, cb);

    return (cross1 * cross2 < 0) && (cross3 * cross4 < 0);
  }

  @override
  void render(Canvas canvas, Size size) {
    List<Offset> visualPoints = normalizedPoints
        .map((point) => convertToRenderPosition(
              relativePoint: point,
              visualImageSize: size,
            ))
        .toList();

    if (visualPoints.isEmpty) return;

    if (visualPoints.length == 1) {
      canvas.drawPoints(PointMode.points, visualPoints, paint);
    }
    for (var index = 0; index < visualPoints.length - 1; index++) {
      canvas.drawLine(
        visualPoints[index],
        visualPoints[index + 1],
        paint,
      );
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln("PolygonAnnotation(")
      ..writeln("  annotationType: ${annotationType.toString()},")
      ..writeln("  strokeWidth: $strokeWidth,")
      ..writeln("  color: $color,")
      ..writeln("  normalizedPoints: $normalizedPoints,")
      ..writeln("  isValidPolygon: $isValid,")
      ..write(")");

    return buffer.toString();
  }
}
