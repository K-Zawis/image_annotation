import 'dart:ui';

import 'package:flutter/material.dart';

import 'annotation_enums.module.dart';

/// An abstract base class for all types of annotations.
///
/// This class serves as the foundation for specific annotation types, such as
/// [ShapeAnnotation] and [TextAnnotation]. It defines the common properties and
/// behaviors that all annotations must have. Subclasses are expected to extend
/// this class and provide additional properties or methods relevant to their
/// specific annotation type.
///
/// Subclasses must also override the [render] method to define how the annotation
/// should be drawn on a [Canvas].
abstract class Annotation {
  /// The path that defines the shape and position of the annotation.
  ///
  /// The [path] represents the geometric form of the annotation. This could be
  /// a series of points, lines, or other shapes that define the annotation's
  /// visual structure.
  final Path path = Path();

  /// The color of the annotation.
  ///
  /// This defines the visual appearance of the annotation, including the color
  /// used for strokes, fills, and other graphical elements.
  final Color color;

  /// The type of annotation that defines the specific shape or structure.
  ///
  /// The [annotationType] determines what kind of annotation is being used,
  /// such as a polygon, text, or line. The type helps distinguish between
  /// different annotation types that may require different rendering logic.
  ///
  /// @see [AnnotationType]
  final AnnotationType annotationType;

  /// Creates an [Annotation] with the specified [color] and [annotationType].
  ///
  /// The constructor initializes the [Annotation] with the provided
  /// [annotationType] and [color], while the [path] is set to its default value.
  ///
  /// - [annotationType] : The type of the annotation, specifying its shape or
  /// structure.
  /// - [color] : The color used to render the annotation.
  Annotation(this.annotationType, {required this.color});

  /// Renders the annotation on the given [canvas] within the specified [size].
  ///
  /// This method is abstract and must be implemented by subclasses. Each specific
  /// annotation type should override this method to provide custom rendering logic
  /// for how the annotation is drawn on the canvas.
  ///
  /// @see
  /// [Canvas]
  /// [AnnotationPainter]
  void render(Canvas canvas, Size size);
}
