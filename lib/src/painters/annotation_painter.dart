import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';

// AnnotationPainter class
class AnnotationPainter extends CustomPainter {
  final AnnotationController controller;

  AnnotationPainter(
    this.controller,
  );

  // Paint annotations and text on the canvas
  @override
  void paint(Canvas canvas, Size size) {
    for (Annotation annotation in controller.annotations) {
      annotation.render(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
