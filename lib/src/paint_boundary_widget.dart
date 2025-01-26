import 'package:flutter/material.dart';

import 'annotation_controller.dart';
import 'annotation_painter.dart';
import 'annotation_models.dart';

class ImageAnnotationPaintBoundary extends StatefulWidget {
  final Image imageWidget;
  final GestureDragStartCallback? onDrawStart;
  final GestureDragEndCallback? onDrawEnd;
  final ImageAnnotationController controller;

  const ImageAnnotationPaintBoundary({
    Key? key,
    required this.imageWidget,
    required this.controller,
    this.onDrawStart,
    this.onDrawEnd,
  }) : super(key: key);

  @override
  State<ImageAnnotationPaintBoundary> createState() => _ImageAnnotationPaintBoundaryState();
}

class _ImageAnnotationPaintBoundaryState extends State<ImageAnnotationPaintBoundary> {
  bool _editing = true;

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
    if (!_editing) return;
    if (widget.controller.currentAnnotation?.runtimeType != ShapeAnnotation) return;

    if (position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= widget.controller.visualImageSize.width &&
        position.dy <= widget.controller.visualImageSize.height) {
      final imagePosition = convertToImagePosition(
          position,
          widget.controller.originalImageSize,
          widget.controller.visualImageSize);

      (widget.controller.currentAnnotation! as ShapeAnnotation)
          .add(imagePosition);
      widget.controller.updateView();
    }
  }

  void _onDrawEnd() {
    if (!widget.controller.canEdit) {
      setState(() {
        _editing = false;
      });
    }
  }

  void _onDrawStart(details) {
    if (widget.controller.canEdit) {
      setState(() {
        _editing = true;
      });
    }

    widget.onDrawStart?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        // height: widget.controller.visualImageSize.height,
        // width: widget.controller.visualImageSize.width,
        child: GestureDetector(
          onPanUpdate: (details) => drawShape(details.localPosition),
          onPanStart: _onDrawStart,
          onPanEnd: (details) {
            _onDrawEnd.call();
            widget.onDrawEnd?.call(details);
          },
          onPanCancel: _onDrawEnd,
          child: CustomPaint(
            foregroundPainter: AnnotationPainter(widget.controller),
            child: widget.imageWidget,
          ),
        ),
      ),
    );
  }
}
