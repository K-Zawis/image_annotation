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
    final maxY = _normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 > y2 ? y1 : y2,
        );

    return Offset(minX, maxY);
  }

  /// Finds the bottom-left point from the list of points.
  Offset? get bottomLeftPoint {
    if (_normalizedPoints.isEmpty) return null;

    final minX = _normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 < x2 ? x1 : x2,
        );
    final minY = _normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 < y2 ? y1 : y2,
        );

    return Offset(minX, minY);
  }

  /// Finds the top-right point from the list of points.
  Offset? get topRightPoint {
    if (_normalizedPoints.isEmpty) return null;

    final maxX = _normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 > x2 ? x1 : x2,
        );
    final maxY = _normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 > y2 ? y1 : y2,
        );

    return Offset(maxX, maxY);
  }

  /// Finds the bottom-right point from the list of points.
  Offset? get bottomRightPoint {
    if (_normalizedPoints.isEmpty) return null;

    final maxX = _normalizedPoints.map((Offset p) => p.dx).reduce(
          (x1, x2) => x1 > x2 ? x1 : x2,
        );
    final minY = _normalizedPoints.map((Offset p) => p.dy).reduce(
          (y1, y2) => y1 < y2 ? y1 : y2,
        );

    return Offset(maxX, minY);
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
