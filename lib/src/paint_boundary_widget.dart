import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

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
  State<ImageAnnotationPaintBoundary> createState() =>
      _ImageAnnotationPaintBoundaryState();
}

class _ImageAnnotationPaintBoundaryState
    extends State<ImageAnnotationPaintBoundary> {
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
    if (widget.controller.currentAnnotation?.runtimeType != ShapeAnnotation)
      return;

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

  void _onDrawEnd(details) {
    if (widget.controller.finalizeOnRelease &&
        widget.controller.annotationLimit != null &&
        widget.controller.annotations.length >=
            widget.controller.annotationLimit!) {
      setState(() {
        _editing = false;
      });
    }

    widget.onDrawEnd?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onPanUpdate: (details) => drawShape(details.localPosition),
        onPanStart: widget.onDrawStart,
        onPanEnd: _onDrawEnd,
        onPanCancel: () {
          if (widget.controller.finalizeOnRelease &&
              widget.controller.annotationLimit != null &&
              widget.controller.annotations.length >=
                  widget.controller.annotationLimit!) {
            setState(() {
              _editing = false;
            });
          }
        },
        child: CustomPaint(
          foregroundPainter: AnnotationPainter(widget.controller),
          child: SizedBox(
            height: widget.controller.visualImageSize.height,
            width: widget.controller.visualImageSize.width,
            child: widget.imageWidget,
          ),
        ),
      ),
    );
  }
}
