import 'package:flutter/material.dart';

import 'annotation_models.dart';
import 'annotation_option.dart';

class ImageAnnotationController extends ChangeNotifier {
  /// Currently displayed annotations on the canvas
  final List<Annotation> _annotations = [];

  /// Current stack of undone annotations ready to be redone
  final List<Annotation> _redoStack = [];

  /// Current annotation
  Annotation? _currentAnnotation;

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
  Annotation? get currentAnnotation => _currentAnnotation;
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
    if (_currentStrokeWidth == newWidth) return;

    _currentStrokeWidth = newWidth;
    notifyListeners();
  }

  set fontSize(double newFontSize) {
    if (_currentFontSize == newFontSize) return;

    _currentFontSize = newFontSize;
    notifyListeners();
  }

  set annotationOption(AnnotationOption newAnnotationOption) {
    if (_currentAnnotationType == newAnnotationOption) return;

    _currentAnnotationType = newAnnotationOption;
    notifyListeners();
  }

  /// Notifies listiners that a new annotation has been added
  void add(Annotation annotation) {
    _currentAnnotation = annotation;

    _annotations.add(annotation);
    _redoStack.clear();

    notifyListeners();
  }

  /// Notifies listeners to undo the last annotation
  void undoAnnotation() {
    if (_annotations.isEmpty) return;

    final lastAnnotation = _annotations.removeLast();
    _redoStack.add(lastAnnotation);

    notifyListeners();
  }

  /// Notifies listeners to redo the last annotation
  void redoAnnotation() {
    if (_redoStack.isEmpty) return;

    final lastUndone = _redoStack.removeLast();
    _annotations.add(lastUndone);

    notifyListeners();
  }

  /// Notifies listeners to clear all annotations.
  void clearAnnotations() {
    if (_annotations.isEmpty) return;

    final clearedAnnotations = List.of(_annotations);
    _annotations.clear();
    _redoStack.addAll(clearedAnnotations);

    notifyListeners();
  }
}
