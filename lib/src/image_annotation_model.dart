import 'package:flutter/material.dart';

import 'annotation_enums.dart';
import 'annotation_models.dart';

class ImageAnnotationModel {
  /// Currently displayed annotations on the canvas
  final List<Annotation> annotations;

  /// Current stack of undone annotations ready to be redone
  final List<List<Annotation>> redoStack;

  /// Original image size for relative points
  final Size? originalImageSize;

  /// Flag to indicate initialization
  final bool hasLoadedSize;

  /// Current annotation type
  final AnnotationOption currentAnnotationType;

  // Current settings for new annotations
  final Color currentColor;
  final double currentStrokeWidth;
  final double currentFontSize;

  ImageAnnotationModel({
    required this.currentAnnotationType,
    this.annotations = const [],
    this.redoStack = const [],
    this.hasLoadedSize = false,
    this.originalImageSize,
    Color? color,
    double? strokeWidth,
    double? fontSize,
  })  : currentColor = color ?? Colors.red,
        currentStrokeWidth = strokeWidth ?? 2.0,
        currentFontSize = fontSize ?? 16.0;

  /// Creates a copy of the model with updated fields
  ImageAnnotationModel copyWith({
    AnnotationOption? currentAnnotationType,
    List<Annotation>? annotations,
    List<List<Annotation>>? redoStack,
    bool? hasLoadedSize,
    Size? originalImageSize,
    Color? currentColor,
    double? currentStrokeWidth,
    double? currentFontSize,
  }) {
    return ImageAnnotationModel(
      currentAnnotationType:
          currentAnnotationType ?? this.currentAnnotationType,
      annotations: annotations ?? this.annotations,
      redoStack: redoStack ?? this.redoStack,
      hasLoadedSize: hasLoadedSize ?? this.hasLoadedSize,
      originalImageSize: originalImageSize ?? this.originalImageSize,
      color: currentColor ?? this.currentColor,
      strokeWidth: currentStrokeWidth ?? this.currentStrokeWidth,
      fontSize: currentFontSize ?? this.currentFontSize,
    );
  }
}
