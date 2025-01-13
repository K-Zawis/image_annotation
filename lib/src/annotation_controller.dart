import 'package:flutter/material.dart';

import 'annotation_action.dart';

class ImageAnnotationController extends ChangeNotifier {
  /// Current annotation color
  Color _currentColor = Colors.red;

  /// Current annotation stroke width
  double _currentStrokeWidth = 2.0;

  /// Internal callback for the widget to listen to specific actions
  final void Function(AnnotationAction action) _onActionTriggered;

  ImageAnnotationController(this._onActionTriggered);

  Color get color => _currentColor;

  double get strokeWidth => _currentStrokeWidth;

  set color(Color newColor) {
    _currentColor = newColor;
    notifyListeners();
  }

  set strokeWidth(double newWidth) {
    _currentStrokeWidth = newWidth;
    notifyListeners();
  }

  /// Triggers callback function
  void _triggerAction(AnnotationAction action) =>
      _onActionTriggered.call(action);

  /// Notifies listeners to undo the last annotation
  void undo() => _triggerAction(AnnotationAction.undo);

  /// Notifies listeners to clear all annotations.
  void clear() => _triggerAction(AnnotationAction.clear);

  /// Notifies listeners to finish the current annotation.
  void finish() => _triggerAction(AnnotationAction.finish);
}
