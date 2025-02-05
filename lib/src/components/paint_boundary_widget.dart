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

  /// Shows the text annotation dialogue with the given [position].
  void _drawText(Offset position) {
    if (widget.controller.annotationType != AnnotationType.text) return;

    Size? boundarySize = _boundaryKey.currentContext?.size;
    if (boundarySize == null) return;

    if (position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= boundarySize.width &&
        position.dy <= boundarySize.height) {
      final textPosition = convertToNormalizedPosition(
        point: position,
        visualImageSize: boundarySize,
      );

      showTextAnnotationDialog(
        context: context,
        relativePosition: textPosition,
        controller: widget.controller,
        visualImageSize: boundarySize,
      );
    }
  }

  /// Updates the current annotation path with the given [position].
  void _drawShape(Offset position) {
    if (!_editing) return;
    if (widget.controller.currentAnnotation?.runtimeType != ShapeAnnotation) return;

    Size? boundarySize = _boundaryKey.currentContext?.size;
    if (boundarySize == null) return;

    if (position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= boundarySize.width &&
        position.dy <= boundarySize.height) {
      final shapePosition = convertToNormalizedPosition(
        point: position,
        visualImageSize: boundarySize,
      );

      (widget.controller.currentAnnotation! as ShapeAnnotation)
          .add(shapePosition);
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
        onPanUpdate: (details) => _drawShape(details.localPosition),
        onPanStart: _onDrawStart,
        onPanEnd: (details) {
          _onDrawEnd.call();
          widget.onDrawEnd?.call(details);
        },
        onPanCancel: _onDrawEnd,
        onTapDown: (details) => _drawText(details.localPosition),
        child: CustomPaint(
          foregroundPainter: AnnotationPainter(widget.controller),
          child: AspectRatio(
            aspectRatio: widget.controller.aspectRatio!,
            child: SizedBox.expand(
              child: widget.imageWidget,
            ),
          ),
        ),
      ),
    );
  }
}
