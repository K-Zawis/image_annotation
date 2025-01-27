import 'package:flutter/material.dart';

import 'image_annotation_controller.dart';
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
  final GlobalKey _boundaryKey = GlobalKey();
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

    Size? boundarySize = _boundaryKey.currentContext?.size;
    if (boundarySize == null) return;

    if (position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= boundarySize.width &&
        position.dy <= boundarySize.height) {
      final imagePosition = convertToImagePosition(
        position,
        widget.controller.originalImageSize!,
        boundarySize,
      );

      (widget.controller.currentAnnotation! as ShapeAnnotation)
          .add(imagePosition);
      widget.controller.updateView();
    }
  }

  void _onDrawEnd() {
    if (!widget.controller.canEditCurrentAnnotation) {
      setState(() {
        _editing = false;
      });
    }
  }

  void _onDrawStart(details) {
    if (widget.controller.canEditCurrentAnnotation) {
      setState(() {
        _editing = true;
      });
    }

    widget.onDrawStart?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boundaryKey,
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
          child: AspectRatio(
            aspectRatio: widget.controller.originalImageSize!.width /
                widget.controller.originalImageSize!.height,
            child: SizedBox.expand(
              child: widget.imageWidget,
            ),
          ),
        ),
      ),
    );
  }
}
