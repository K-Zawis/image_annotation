import 'package:flutter/material.dart';
import 'annotation_controller.dart';
import 'annotation_painter.dart';
import 'annotation_models.dart';

class ImageAnnotationPaintBoundary extends StatelessWidget {
  final String imagePath;
  final Size imageSize;
  final Offset imageOffset;
  final GestureDragStartCallback? onDrawStart;
  final GestureDragEndCallback? onDrawEnd;
  final ImageAnnotationController controller;

  /// Updates the current annotation path with the given [position].
  void drawShape(Offset position) {
    if (controller.currentAnnotation?.runtimeType != ShapeAnnotation) return;

    if (position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= imageSize.width &&
        position.dy <= imageSize.height) {
      (controller.currentAnnotation! as ShapeAnnotation).add(position);
    }
  }

  const ImageAnnotationPaintBoundary({
    Key? key,
    required this.imagePath,
    required this.imageSize,
    required this.imageOffset,
    required this.controller,
    this.onDrawStart,
    this.onDrawEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            width: imageSize.width,
            height: imageSize.height,
          ),
          Positioned(
            left: imageOffset.dx,
            top: imageOffset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                drawShape(details.localPosition);
              },
              onPanStart: onDrawStart,
              onPanEnd: onDrawEnd,
              child: CustomPaint(
                painter: AnnotationPainter(
                  controller.annotations,
                ),
                size: imageSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
