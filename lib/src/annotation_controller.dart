import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'annotation_models.dart';
import 'annotation_enums.dart';

class ImageAnnotationController extends ChangeNotifier {
  /// Currently displayed annotations on the canvas
  final List<Annotation> _annotations = [];

  /// Current stack of undone annotations ready to be redone
  final List<List<Annotation>> _redoStack = [];

  /// Flag to indicate initialization
  bool _hasLoadedSize = false;

  /// Original image size for relative points
  late Size _originalImageSize;

  /// Visual image size on the screen for rendering points
  late Size visualImageSize;

  /// Current annotation color
  Color _currentColor;

  /// Current annotation stroke width
  double _currentStrokeWidth;

  /// Current text annotation size
  double _currentFontSize;

  /// Current annotation type
  AnnotationOption _currentAnnotationType;

  ImageAnnotationController(
    this._currentAnnotationType, {
    Color? color,
    double? strokeWidth,
    double? fontSize,
  })  : assert(strokeWidth == null || strokeWidth > 0.0),
        assert(fontSize == null || fontSize > 0.0),
        _currentColor = color ?? Colors.red,
        _currentStrokeWidth = strokeWidth ?? 2.0,
        _currentFontSize = fontSize ?? 16.0;

  List<Annotation> get annotations => List.unmodifiable(_annotations);
  Annotation? get currentAnnotation =>
      _annotations.isNotEmpty ? _annotations.last : null;
  Size get originalImageSize => _originalImageSize;
  bool get hasLoadedSize => _hasLoadedSize;
  Color get color => _currentColor;
  double get strokeWidth => _currentStrokeWidth;
  double get fontSize => _currentFontSize;
  AnnotationOption get annotationType => _currentAnnotationType;
  bool get canUndo => _annotations.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  set color(Color newColor) {
    if (_currentColor == newColor) return;

    _currentColor = newColor;
    notifyListeners();
  }

  set strokeWidth(double newWidth) {
    if (_currentStrokeWidth == newWidth || newWidth <= 0.0) return;

    _currentStrokeWidth = newWidth;
    notifyListeners();
  }

  set fontSize(double newFontSize) {
    if (_currentFontSize == newFontSize || newFontSize <= 0.0) return;

    _currentFontSize = newFontSize;
    notifyListeners();
  }

  set annotationType(AnnotationOption newAnnotationOption) {
    if (_currentAnnotationType == newAnnotationOption) return;

    _currentAnnotationType = newAnnotationOption;
    notifyListeners();
  }

  Future<void> loadImageSize(
    ImageProvider imageProvider,
    BuildContext context,
    EdgeInsets padding,
  ) async {
    final completer = Completer<ui.Image>();

    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );

    final ui.Image loadedImage = await completer.future;

    _originalImageSize = Size(
      loadedImage.width.toDouble(),
      loadedImage.height.toDouble(),
    );

    if (!context.mounted) return;

    final double scale = _calculateScaleFactor(
      imageSize: _originalImageSize,
      screenSize: MediaQuery.of(context).size,
      padding: padding,
    );

    visualImageSize = Size(
      loadedImage.width * scale,
      loadedImage.height * scale,
    );

    _hasLoadedSize = true;
    notifyListeners();
  }

  /// Calculates the scale factor to fit an image within the screen
  /// while preserving its aspect ratio.
  double _calculateScaleFactor({
    required Size imageSize,
    required Size screenSize,
    required EdgeInsets padding,
  }) {
    final double adjustedWidth = screenSize.width - padding.horizontal;
    final double adjustedHeight = screenSize.height - padding.vertical;

    double heightScale = adjustedHeight / imageSize.height;
    double widthScale = adjustedWidth / imageSize.width;

    return heightScale < widthScale ? heightScale : widthScale;
  }

  void updateView() {
    notifyListeners();
  }

  /// Notifies listiners that a new annotation has been added
  void add(Annotation annotation) {
    _annotations.add(annotation);
    _redoStack.clear();

    notifyListeners();
  }

  /// Notifies listeners to undo the last annotation
  void undoAnnotation() {
    if (!canUndo) return;

    final Annotation lastAnnotation = _annotations.removeLast();
    _redoStack.add([lastAnnotation]);

    notifyListeners();
  }

  /// Notifies listeners to redo the last annotation
  void redoAnnotation() {
    if (!canRedo) return;

    final lastUndone = _redoStack.removeLast();
    _annotations.addAll(lastUndone);

    notifyListeners();
  }

  /// Notifies listeners to clear all annotations.
  void clearAnnotations() {
    if (!canUndo) return;

    final clearedAnnotations = List.of(_annotations);
    _annotations.clear();
    _redoStack.add(clearedAnnotations);

    notifyListeners();
  }

  @override
  void dispose() {
    _annotations.clear();
    _redoStack.clear();

    super.dispose();
  }
}
