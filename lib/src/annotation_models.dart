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

class TextAnnotation extends Annotation {
  final Offset position;
  final String text;
  final double fontSize;

  TextAnnotation({
    required this.position,
    required this.text,
    this.fontSize = 16.0,
    Color textColor = Colors.black,
  }) : super(textColor);

  // TODO: add relative position to text as well!
}

/// Represents a shape annotation, which consists of a series of points relative
/// to the image's dimensions, a stroke width, and a type that defines the shape.
///
/// This class is used to store and manage points for shapes like lines, rectangles,
/// and ovals.
/// 
/// @see
/// [Annotation]
class ShapeAnnotation extends Annotation {
  /// The list of points relative to the original image's dimensions.
  ///
  /// These points define the shape's outline or structure.
  final List<Offset> _relativePoints;

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
  /// - [annotationType]: The [AnnotationType] of this shape.
  /// - [strokeWidth]: The width of the stroke used to draw the shape.
  ///   Defaults to `2.0`.
  /// - [color]: The colour of the annotation. Defaults to [Colors.red].
  ShapeAnnotation(
    this.annotationType, {
    this.strokeWidth = 2.0,
    Color color = Colors.red,
  })  : _relativePoints = [],
        super(color);

  /// Provides an unmodifiable view of the relative points of the shape.
  List<Offset> get relativePoints => List.unmodifiable(_relativePoints);

  /// Retrieves the first point in the list of relative points, if it exists.
  ///
  /// Returns `null` if the list is empty.
  Offset? get firstRelativePoint => _relativePoints.firstOrNull;

  /// Retrieves the last point in the list of relative points, if it exists.
  ///
  /// Returns `null` if the list is empty.
  Offset? get lastRelativePoint => _relativePoints.lastOrNull;

  /// Adds a new point to the list of relative points.
  ///
  /// - [point]: The point to be added, which should be relative to the image's dimensions.
  void add(Offset point) {
    _relativePoints.add(point);
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('ShapeAnnotation(')
      ..writeln('  annotationType: ${annotationType.toString()},')
      ..writeln('  strokeWidth: $strokeWidth,')
      ..writeln('  color: $color,');

    if (annotationType == AnnotationType.line) {
      buffer.writeln('  relativePoints: $relativePoints,');
    } else {
      buffer.writeln('  firstRelativePoint: $firstRelativePoint,');
      buffer.writeln('  lastRelativePoint: $lastRelativePoint,');
    }

    buffer.write(')');
    return buffer.toString();
  }
}
