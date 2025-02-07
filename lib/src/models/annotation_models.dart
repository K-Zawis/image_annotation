import 'package:flutter/material.dart';

import 'annotation_enums.dart';

/// An abstract base class for all types of annotations.
///
/// This class serves as the foundation for specific annotation types,
/// such as [ShapeAnnotation] and [TextAnnotation]. It defines the common
/// properties and behaviours that all annotations must have.
///
/// Subclasses are expected to extend this class and provide additional
/// properties or methods relevant to their specific annotation type.
abstract class Annotation {
  /// The colour of the annotation.
  ///
  /// This defines the visual appearance of the annotation, such as the stroke
  /// colour.
  final Color color;

  /// Creates an [Annotation] instance with the specified [color].
  ///
  /// - [color] : The colour of the annotation.
  Annotation(this.color);
}

/// Represents a text annotation, which consists of a normalized position, a text
/// string, and a normalized font size.
///
/// This class is used to store and manage text annotations, ensuring they
/// scale properly when the image is resized.
///
/// @see
/// [Annotation]
class TextAnnotation extends Annotation {
  /// The normalized position of the text.
  ///
  /// The [Offset] points are values between `0` and `1`.
  final Offset _normalizedPosition;

  /// The text content of the annotation.
  final String text;

  /// The normalized font size.
  ///
  /// Defaults to `0.0`, but when rendered, it should be scaled
  /// according to the image's visual size.
  final double normalizedFontSize;

  /// Creates a [TextAnnotation] instance.
  /// - [normalizedPosition] : The normalized [Offset] of the text.
  ///   Values should be between `0` and `1`.
  /// - [text] : The annotation text content.
  /// - [normalizedFontSize] : The normalized font size.
  ///   Defaults to `0.0`.
  ///   Values should be between `0` and `1`.
  /// - [textColor] : The color of the text. Defaults to [Colors.black].
  TextAnnotation({
    required Offset normalizedPosition,
    required this.text,
    this.normalizedFontSize = 0.0,
    Color textColor = Colors.black,
  })  : assert(
          normalizedPosition.dx >= 0 && normalizedPosition.dx <= 1,
          'X coordinate is not normalized.',
        ),
        assert(
          normalizedPosition.dy >= 0 && normalizedPosition.dy <= 1,
          'Y coordinate is not normalized.',
        ),
        _normalizedPosition = normalizedPosition,
        super(textColor);

  Offset get normalizedPosition => _normalizedPosition;

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln("TextAnnotation(")
      ..writeln("  text: \"$text\",")
      ..writeln("  normalizedPosition: $_normalizedPosition,")
      ..writeln("  normalizedFontSize: $normalizedFontSize,")
      ..writeln("  color: $color,")
      ..write(")");
    return buffer.toString();
  }
}

/// Represents a shape annotation, which consists of a series of normalized points,
/// a stroke width, and a type that defines the shape.
///
/// This class is used to store and manage points for shapes like lines, rectangles,
/// and ovals.
///
/// @see
/// [Annotation]
class ShapeAnnotation extends Annotation {
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

  /// The type of the annotation that defines the shape.
  ///
  /// @see
  /// [AnnotationType]
  final AnnotationType annotationType;

  /// Creates a [ShapeAnnotation] instance.
  ///
  /// - [annotationType] : The [AnnotationType] of this shape.
  /// - [strokeWidth] : The width of the stroke used to draw the shape.
  ///   Defaults to `2.0`.
  /// - [color] : The colour of the annotation. Defaults to [Colors.red].
  ShapeAnnotation(
    this.annotationType, {
    this.strokeWidth = 2.0, // TODO: normalize this value
    Color color = Colors.red,
  })  : _normalizedPoints = [],
        super(color);

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
  String toString() {
    final buffer = StringBuffer()
      ..writeln("ShapeAnnotation(")
      ..writeln("  annotationType: ${annotationType.toString()},")
      ..writeln("  strokeWidth: $strokeWidth,")
      ..writeln("  color: $color,");

    if (annotationType == AnnotationType.line) {
      buffer.writeln("  normalizedPoints: $normalizedPoints,");
    } else {
      buffer.writeln("  firstNormalizedPoint: $firstNormalizedPoint,");
      buffer.writeln("  lastNormalizedPoint: $lastNormalizedPoint,");
    }

    buffer.write(")");
    return buffer.toString();
  }
}

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
    if (_normalizedPoints.length < 4) return false;
    if (!_isRingClosed()) return false;
    if (_hasSpikesOrPunctures()) return false;

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
  bool _hasSpikesOrPunctures() {
    for (int i = 0; i < _normalizedPoints.length - 2; i++) {
      for (int j = i + 2; j < _normalizedPoints.length - 1; j++) {
        if (_linesIntersect(
          _normalizedPoints[i],
          _normalizedPoints[i + 1],
          _normalizedPoints[j],
          _normalizedPoints[j + 1],
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
  String toString() {
    final buffer = StringBuffer()
      ..writeln("PolygonAnnotation(")
      ..writeln("  annotationType: ${annotationType.toString()},")
      ..writeln("  strokeWidth: $strokeWidth,")
      ..writeln("  color: $color,")
      ..writeln("  normalizedPoints: $normalizedPoints,")
      ..write(")");

    return buffer.toString();
  }
}

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

  /// Creates a [DetectedAnnotation] instance.
  ///
  /// - [label] : The label of the detected object.
  /// - [confidenceScore] : The confidence score of the detection.
  /// - [normalizedPoints] : A list of normalized [Offset] objects defining the rectangle.
  /// - [strokeWidth] : The width of the stroke used to draw the shape.
  /// - [color] : The color of the annotation.
  DetectedAnnotation({
    required this.label,
    required this.confidenceScore,
    required List<Offset> normalizedPoints,
    double strokeWidth = 2.0,
    Color color = Colors.red,
  })  : assert(
          normalizedPoints.every((p) => p.dx >= 0 && p.dx <= 1),
          'X coordinate is not normalized.',
        ),
        assert(
          normalizedPoints.every((p) => p.dy >= 0 && p.dy <= 1),
          'Y coordinate is not normalized.',
        ),
        super(
          AnnotationType.rectangle,
          strokeWidth: strokeWidth,
          color: color,
        ) {
    for (final point in normalizedPoints) {
      add(point);
    }
  }

  /// Finds the top-left point from the list of points.
  Offset? get topLeftPoint {
    if (_normalizedPoints.isEmpty) return null;

    final minX = _normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 < x2 ? x1 : x2,
        );
    final minY = _normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 < y2 ? y1 : y2,
        );

    return Offset(minX, minY);
  }

  /// Finds the bottom-left point from the list of points.
  Offset? get bottomLeftPoint {
    if (_normalizedPoints.isEmpty) return null;

    final minX = _normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 < x2 ? x1 : x2,
        );
    final maxY = _normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 > y2 ? y1 : y2,
        );

    return Offset(minX, maxY);
  }

  /// Finds the top-right point from the list of points.
  Offset? get topRightPoint {
    if (_normalizedPoints.isEmpty) return null;

    final maxX = _normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 > x2 ? x1 : x2,
        );
    final minY = _normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 < y2 ? y1 : y2,
        );

    return Offset(maxX, minY);
  }

  /// Finds the bottom-right point from the list of points.
  Offset? get bottomRightPoint {
    if (_normalizedPoints.isEmpty) return null;

    final maxX = _normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 > x2 ? x1 : x2,
        );
    final maxY = _normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 > y2 ? y1 : y2,
        );

    return Offset(maxX, maxY);
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
