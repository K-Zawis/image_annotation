import 'package:flutter/material.dart';

import 'annotation_enums.dart';
import 'annotation_models.dart';

/// A model representing the state and configuration of an image annotation tool.
class ImageAnnotationModel {
  /// The list of currently displayed annotations on the canvas.
  ///
  /// Each [Annotation] represents a drawable or editable item on the canvas.
  final List<Annotation> annotations;

  /// The stack of undone annotations.
  ///
  /// Each entry in the [redoStack] is a snapshot of annotations to allow
  /// restoring previous states.
  final List<List<Annotation>> redoStack;

  /// The original size of the image being annotated.
  ///
  /// Used for converting points and dimensions between relative and absolute
  /// coordinates.
  Size? originalImageSize;

  /// The currently selected annotation type for new annotations.
  ///
  /// Defines whether the user is creating a freehand drawing, a rectangle,
  /// a circle, or a text annotation.
  AnnotationType currentAnnotationType;

  /// The current colour for new annotations.
  ///
  /// This determines the stroke colour of any annotation being created.
  Color currentColor;

  /// The current stroke width for new annotations.
  ///
  /// Applies to shapes like lines or borders of rectangles and circles.
  double currentStrokeWidth;

  /// The current font size for text annotations.
  ///
  /// Applies only to text annotations.
  double currentFontSize;

  /// Creates an instance of [ImageAnnotationModel].
  ///
  /// [currentAnnotationType] is required and must be provided.
  ///
  /// Optional parameters:
  /// - [annotations] : Defaults to an empty mutable list.
  /// - [redoStack] : Defaults to an empty mutable list.
  /// - [originalImageSize] : Defaults to `null`.
  /// - [color] : Defaults to `Colors.red`.
  /// - [strokeWidth] : Defaults to `2.0`.
  /// - [fontSize] : Defaults to `16.0`.
  ImageAnnotationModel({
    required this.currentAnnotationType,
    this.originalImageSize,
    Color? color,
    double? strokeWidth,
    double? fontSize,
    List<Annotation>? annotations,
    List<List<Annotation>>? redoStack,
  })  : currentColor = color ?? Colors.red,
        currentStrokeWidth = strokeWidth ?? 2.0,
        currentFontSize = fontSize ?? 16.0,
        annotations = annotations ?? <Annotation>[],
        redoStack = redoStack ?? <List<Annotation>>[];

  /// Creates a copy of the model with updated fields.
  ///
  /// Allows you to create a new instance of [ImageAnnotationModel] while
  /// overriding specific properties. All unspecified properties will default
  /// to the values of the current instance.
  ///
  /// Example usage:
  /// ```dart
  /// final newModel = currentModel.copyWith(
  ///   currentAnnotationType: AnnotationOption.rectangle,
  ///   currentColor: Colors.blue,
  /// );
  /// ```
  ///
  /// Parameters:
  /// - [annotationType] : The new annotation type.
  /// - [annotations] : The updated list of annotations.
  /// - [redoStack] : The updated redo stack.
  /// - [originalImageSize] : The new original image size.
  /// - [color] : The updated colour for annotations.
  /// - [strokeWidth] : The new stroke width.
  /// - [fontSize] : The updated font size.
  ImageAnnotationModel copyWith({
    AnnotationType? annotationType,
    List<Annotation>? annotations,
    List<List<Annotation>>? redoStack,
    Size? originalImageSize,
    Color? color,
    double? strokeWidth,
    double? fontSize,
  }) {
    return ImageAnnotationModel(
      currentAnnotationType: annotationType ?? currentAnnotationType,
      annotations: annotations ?? this.annotations,
      redoStack: redoStack ?? this.redoStack,
      originalImageSize: originalImageSize ?? this.originalImageSize,
      color: color ?? currentColor,
      strokeWidth: strokeWidth ?? currentStrokeWidth,
      fontSize: fontSize ?? currentFontSize,
    );
  }
}
