import 'package:flutter/material.dart';

import 'annotation_action.dart';

class ImageAnnotationController extends ChangeNotifier {
  /// Current annotation color
  Color _currentColor = Colors.red;

  /// Current annotation stroke width
  double _currentStrokeWidth = 2.0;

  /// Internal callback for the widget to listen to specific actions
  void Function(AnnotationAction action)? _onActionTriggered;

  /// Sets the callback function that will handle the actions (undo, clear, finish).
  /// This should only be set once and is handled by [ImageAnnotationWidget]. Calling 
  /// this multiple times will result in an exception.
  void setOnActionTriggered(void Function(AnnotationAction action) callback) {
    if (_onActionTriggered != null) {
      throw Exception('Action handler is already set!');
    }
    _onActionTriggered = callback;
  }

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
      _onActionTriggered?.call(action);

  /// Notifies listeners to undo the last annotation
  void undo() => _triggerAction(AnnotationAction.undo);

  /// Notifies listeners to clear all annotations.
  void clear() => _triggerAction(AnnotationAction.clear);

  /// Notifies listeners to finish the current annotation.
  void finish() => _triggerAction(AnnotationAction.finish);

  @override
  void dispose() {
    _onActionTriggered = null;
    super.dispose();
  }
}
