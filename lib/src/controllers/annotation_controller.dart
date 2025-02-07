import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/models.dart';

/// A controller to manage the state and behaviour of the image annotation tool.
///
/// This class serves as the bridge between the UI and the model, providing
/// state management and utility methods for annotations.
class AnnotationController extends ChangeNotifier {
  /// The current annotation model holding all state data.
  final ImageAnnotationModel _model;

  /// The maximum number of annotations allowed.
  ///
  /// If `null`, there is no limit to the number of annotations.
  ///
  /// Set when `ImageAnnotationController` is initialised.
  final int? _annotationLimit;

  /// Determines if [ShapeAnnotation] is finalised immediately after drawing.
  ///
  /// When `true`, shape annotations are considered complete as soon as
  /// [onPanStart] is fired. Defaults to `false`.
  final bool _finalizeOnRelease;

  /// Creates an instance of [AnnotationController].
  ///
  /// - [currentAnnotationType] is required and determines the initial annotation type.
  /// - Optional parameters:
  ///   - [color]: The initial colour for annotations.
  ///   - [strokeWidth]: The initial stroke width. Must be greater than `0.0`.
  ///   - [fontSize]: The initial font size for text annotations. Must be greater than `0.0`.
  ///   - [annotationLimit]: The maximum number of annotations allowed. Defaults to `null` (no limit).
  ///   - [finalizeOnRelease]: Determines if shapes are finalised immediately. Defaults to `false`.
  AnnotationController(
    AnnotationType currentAnnotationType, {
    Color? color,
    double? strokeWidth,
    double? fontSize,
    int? annotationLimit,
    bool finalizeOnRelease = false,
  })  : assert(strokeWidth == null || strokeWidth > 0.0),
        assert(fontSize == null || fontSize > 0.0),
        _annotationLimit = annotationLimit,
        _finalizeOnRelease = finalizeOnRelease,
        _model = ImageAnnotationModel(
          currentAnnotationType: currentAnnotationType,
          color: color,
          strokeWidth: strokeWidth,
          fontSize: fontSize,
        );

  // ==== GETTERS ====

  /// An unmodifiable list of the current annotations.
  List<Annotation> get annotations => List.unmodifiable(_model.annotations);

  /// The size of the original image being annotated.
  ///
  /// Used for converting points and dimensions between relative and absolute
  /// coordinates.
  ///
  /// Returns `null` if the size has not been loaded yet.
  Size? get originalImageSize => _model.originalImageSize;

  /// The aspect ratio of the original image being annotated.
  ///
  /// Used for maintaining the aspect ratio of the image within
  /// the package
  ///
  /// Returns `null` if the size has not been loaded yet.
  double? get aspectRatio => originalImageSize != null
      ? originalImageSize!.width / originalImageSize!.height
      : null;

  /// The current colour for annotations.
  Color get color => _model.currentColor;

  /// The current stroke width for annotations.
  double get strokeWidth => _model.currentStrokeWidth;

  /// The current font size for text annotations.
  double get fontSize => _model.currentFontSize;

  /// The currently selected annotation type.
  AnnotationType get annotationType => _model.currentAnnotationType;

  /// Whether the size of the original image has been loaded.
  bool get hasLoadedSize => _model.originalImageSize != null;

  /// Whether undo operation is possible.
  bool get canUndo => _model.annotations.isNotEmpty;

  /// Whether redo operation is possible.
  bool get canRedo => _model.redoStack.isNotEmpty;

  /// The maximum number of annotations allowed.
  ///
  /// Returns `null` if no limit is set.
  int? get annotationLimit => _annotationLimit;

  /// Whether shape annotations are finalised immediately after drawing.
  bool get finalizeOnRelease => _finalizeOnRelease;

  /// Whether the current annotation can be edited after being drawn
  bool get canEditCurrentAnnotation =>
      !finalizeOnRelease ||
      annotationLimit == null ||
      annotations.length < annotationLimit!;

  /// The most recently added annotation, if any.
  Annotation? get currentAnnotation =>
      annotations.isNotEmpty ? annotations.last : null;

  bool get isShape =>
      currentAnnotation != null &&
      currentAnnotation.runtimeType == ShapeAnnotation;

  bool get isText =>
      currentAnnotation != null &&
      currentAnnotation.runtimeType == TextAnnotation;

  // ==== SETTERS ====

  /// Updates the colour for new annotations.
  ///
  /// Notifies listeners if the value changes.
  set color(Color newColor) {
    if (color == newColor) return;

    _model.currentColor = newColor;
    notifyListeners();
  }

  /// Updates the stroke width for new annotations.
  ///
  /// Notifies listeners if the value changes. The new value must be greater than `0.0`.
  set strokeWidth(double newWidth) {
    if (strokeWidth == newWidth || newWidth <= 0.0) return;

    _model.currentStrokeWidth = newWidth;
    notifyListeners();
  }

  /// Updates the font size for text annotations.
  ///
  /// Notifies listeners if the value changes. The new value must be greater than `0.0`.
  set fontSize(double newFontSize) {
    if (fontSize == newFontSize || newFontSize <= 0.0) return;

    _model.currentFontSize = newFontSize;
    notifyListeners();
  }

  /// Updates the current annotation type.
  ///
  /// Notifies listeners if the value changes.
  set annotationType(AnnotationType newAnnotationOption) {
    if (annotationType == newAnnotationOption) return;

    _model.currentAnnotationType = newAnnotationOption;
    notifyListeners();
  }

  // ==== FUNCTIONS ====

  /// Manually triggers a UI update.
  void updateView() {
    notifyListeners();
  }

  /// Loads the size of the image being annotated.
  ///
  /// Resolves the [imageProvider] to determine its dimensions and updates the model.
  Future<void> loadImageSize(
    ImageProvider imageProvider,
  ) async {
    final completer = Completer<ui.Image>();

    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );

    final ui.Image loadedImage = await completer.future;

    _model.originalImageSize = Size(
      loadedImage.width.toDouble(),
      loadedImage.height.toDouble(),
    );

    notifyListeners();
  }

  /// Adds a new annotation to the list and clears the redo stack.
  ///
  /// Notifies listeners if the value changes. Does nothing if the annotation limit is reached.
  void add(Annotation annotation) {
    if (_annotationLimit != null && annotations.length >= _annotationLimit)
      return;

    _model.annotations.add(annotation);
    _model.redoStack.clear();

    notifyListeners();
  }

  /// Undoes the most recent annotation.
  ///
  /// Notifies listeners if the value changes. Moves the undone annotation to the redo stack.
  void undoAnnotation() {
    if (!canUndo) return;

    final lastAnnotation = _model.annotations.removeLast();
    _model.redoStack.add([lastAnnotation]);

    notifyListeners();
  }

  /// Redoes the most recently undone annotation(s).
  ///
  /// Notifies listeners if the value changes. Moves the annotation(s) back to the list of annotations.
  void redoAnnotation() {
    if (!canRedo) return;

    final lastUndone = _model.redoStack.removeLast();
    _model.annotations.addAll(lastUndone);

    notifyListeners();
  }

  /// Clears all annotations and moves them to the redo stack.
  ///
  /// Notifies listeners if the value changes.
  void clearAnnotations() {
    if (!canUndo) return;

    final clearedAnnotations = List.of(_model.annotations);
    _model.redoStack.add(clearedAnnotations);
    _model.annotations.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    _model.annotations.clear();
    _model.redoStack.clear();
    super.dispose();
  }
}
