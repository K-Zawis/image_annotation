import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'annotation_models.dart';
import 'annotation_enums.dart';
import 'image_annotation_model.dart';

class ImageAnnotationController extends ChangeNotifier {
  /// Current annotation model
  ImageAnnotationModel _model;

  /// Max annotation limit
  ///
  /// Defaults to null which means no limit
  final int? _annotationLimit;

  /// Whether the [ShapeAnnotation] is considered complete immedietly after drawing.
  ///
  /// Will cause [ShapeAnnotation] to be added to [_controller.annotations] when onPanStart is fired.
  ///
  /// Default behaviour sets this to false.
  final bool _finalizeOnRelease;

  ImageAnnotationController(
    AnnotationOption currentAnnotationType, {
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

  // model getters
  List<Annotation> get annotations => List.unmodifiable(_model.annotations);
  Size? get originalImageSize => _model.originalImageSize;
  bool get hasLoadedSize => _model.hasLoadedSize;
  Color get color => _model.currentColor;
  double get strokeWidth => _model.currentStrokeWidth;
  double get fontSize => _model.currentFontSize;
  AnnotationOption get annotationType => _model.currentAnnotationType;
  bool get canUndo => _model.annotations.isNotEmpty;
  bool get canRedo => _model.redoStack.isNotEmpty;

  // getters
  int? get annotationLimit => _annotationLimit;
  bool get finalizeOnRelease => _finalizeOnRelease;
  bool get canEdit =>
      !finalizeOnRelease ||
      annotationLimit == null ||
      annotations.length < annotationLimit!;
  Annotation? get currentAnnotation =>
      annotations.isNotEmpty ? annotations.last : null;

  //setters
  set color(Color newColor) {
    if (color == newColor) return;

    // _model = _model.copyWith(currentColor: newColor);
    _model.currentColor = newColor;
    notifyListeners();
  }

  set strokeWidth(double newWidth) {
    if (strokeWidth == newWidth || newWidth <= 0.0) return;

    // _model = _model.copyWith(currentStrokeWidth: newWidth);
    _model.currentStrokeWidth = newWidth;
    notifyListeners();
  }

  set fontSize(double newFontSize) {
    if (fontSize == newFontSize || newFontSize <= 0.0) return;

    // _model = _model.copyWith(currentFontSize: newFontSize);
    _model.currentFontSize = newFontSize;
    notifyListeners();
  }

  set annotationType(AnnotationOption newAnnotationOption) {
    if (annotationType == newAnnotationOption) return;

    // _model = _model.copyWith(currentAnnotationType: newAnnotationOption);
    _model.currentAnnotationType = newAnnotationOption;
    notifyListeners();
  }

  // functions
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

    _model = _model.copyWith(
        originalImageSize: Size(
          loadedImage.width.toDouble(),
          loadedImage.height.toDouble(),
        ),
        hasLoadedSize: true);

    notifyListeners();
  }

  void updateView() {
    notifyListeners();
  }

  /// Notifies listiners that a new annotation has been added
  void add(Annotation annotation) {
    if (_annotationLimit != null && annotations.length >= _annotationLimit) return;

    // _model = _model.copyWith(
    //   annotations: [..._model.annotations, annotation],
    //   redoStack: [],
    // );

    _model.annotations.add(annotation);
    _model.redoStack.clear();

    notifyListeners();
  }

  /// Notifies listeners to undo the last annotation
  void undoAnnotation() {
    if (!canUndo) return;

    final lastAnnotation = _model.annotations.last;
    _model = _model.copyWith(
      annotations: _model.annotations.sublist(0, _model.annotations.length - 1),
      redoStack: [
        ..._model.redoStack,
        [lastAnnotation]
      ],
    );

    notifyListeners();
  }

  /// Notifies listeners to redo the last annotation
  void redoAnnotation() {
    if (!canRedo) return;

    final lastUndone = _model.redoStack.last;
    _model = _model.copyWith(
      annotations: [..._model.annotations, ...lastUndone],
      redoStack: _model.redoStack.sublist(0, _model.redoStack.length - 1),
    );

    notifyListeners();
  }

  /// Notifies listeners to clear all annotations.
  void clearAnnotations() {
    if (!canUndo) return;

    final clearedAnnotations = List.of(_model.annotations);
    _model = _model.copyWith(
      annotations: [],
      redoStack: [..._model.redoStack, clearedAnnotations],
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _model.annotations.clear();
    _model.redoStack.clear();

    super.dispose();
  }
}
