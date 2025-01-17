import 'package:flutter/material.dart';
import 'annotation_controller.dart';
import 'annotation_painter.dart';
import 'annotation_models.dart';

class ImageAnnotationPaintBoundary extends StatelessWidget {
  final Image imageWidget;
  final GestureDragStartCallback? onDrawStart;
  final GestureDragEndCallback? onDrawEnd;
  final ImageAnnotationController controller;

  Offset convertToImagePosition(
    Offset viewPosition,
    Size imageSize,
    Size visualImageSize,
  ) {
    final double scaleX = imageSize.width / visualImageSize.width;
    final double scaleY = imageSize.height / visualImageSize.height;

    return Offset(
      viewPosition.dx * scaleX,
      viewPosition.dy * scaleY,
    );
  }

  /// Updates the current annotation path with the given [position].
  void drawShape(Offset position) {
    if (controller.currentAnnotation?.runtimeType != ShapeAnnotation) return;

    if (position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= controller.visualImageSize.width &&
        position.dy <= controller.visualImageSize.height) {
      final imagePosition = convertToImagePosition(
          position, controller.originalImageSize, controller.visualImageSize);

      (controller.currentAnnotation! as ShapeAnnotation).add(imagePosition);
    }
  }

  const ImageAnnotationPaintBoundary({
    Key? key,
    required this.imageWidget,
    required this.controller,
    this.onDrawStart,
    this.onDrawEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onPanUpdate: (details) => drawShape(details.localPosition),
        onPanStart: onDrawStart,
        onPanEnd: onDrawEnd,
        child: CustomPaint(
          foregroundPainter: AnnotationPainter(controller),
          child: SizedBox(
            height: controller.visualImageSize.height,
            width: controller.visualImageSize.width,
            child: imageWidget,
          ),
        ),
      ),
    );
  }
}
