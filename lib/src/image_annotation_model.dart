import 'package:flutter/material.dart';

import 'annotation_enums.dart';
import 'annotation_models.dart';

class ImageAnnotationModel {
  /// Currently displayed annotations on the canvas
  final List<Annotation> annotations;

  /// Current stack of undone annotations ready to be redone
  final List<List<Annotation>> redoStack;

  /// Original image size for relative points
  Size? originalImageSize;

  /// Flag to indicate initialization
  bool hasLoadedSize;

  /// Current annotation type
  AnnotationOption currentAnnotationType;

  // Current settings for new annotations
  Color currentColor;
  double currentStrokeWidth;
  double currentFontSize;

  ImageAnnotationModel({
    required this.currentAnnotationType,
    this.hasLoadedSize = false,
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
