import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../painters/painters.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class ImageAnnotationPaintBoundary extends StatefulWidget {
  final Image imageWidget;
  final GestureDragStartCallback? onDrawStart;
  final GestureDragEndCallback? onDrawEnd;
  final AnnotationController controller;

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
        viewPosition: position,
        originalImageSize: widget.controller.originalImageSize!,
        visualImageSize: boundarySize,
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
        onTapDown: (details) {
          if (widget.controller.annotationType != AnnotationType.text) return;

          Size? boundarySize = _boundaryKey.currentContext?.size;
          if (boundarySize == null) return;

          final imagePosition = convertToImagePosition(
            viewPosition: details.localPosition,
            originalImageSize: widget.controller.originalImageSize!,
            visualImageSize: boundarySize,
          );

          showTextAnnotationDialog(
            context,
            imagePosition,
            widget.controller,
          );
        },
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
