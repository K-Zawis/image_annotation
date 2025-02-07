import 'dart:developer';

import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../painters/painters.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class AnnotationPaintBoundary extends StatefulWidget {
  final Image imageWidget;
  final GestureDragStartCallback? onDrawStart;
  final GestureDragEndCallback? onDrawEnd;
  final AnnotationController controller;

  const AnnotationPaintBoundary({
    Key? key,
    required this.imageWidget,
    required this.controller,
    this.onDrawStart,
    this.onDrawEnd,
  }) : super(key: key);

  @override
  State<AnnotationPaintBoundary> createState() =>
      _AnnotationPaintBoundaryState();
}

class _AnnotationPaintBoundaryState extends State<AnnotationPaintBoundary> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _editing = true;
  bool _drawingPolygon = false;

  void _draw(Offset position) {
    Size? boundarySize = _boundaryKey.currentContext?.size;
    if (boundarySize == null ||
        position.dx < 0 ||
        position.dy < 0 ||
        position.dx > boundarySize.width ||
        position.dy > boundarySize.height) {
      return;
    }

    final normalizedPosition = convertToNormalizedPosition(
      point: position,
      visualImageSize: boundarySize,
    );

    final Annotation? annotation = widget.controller.currentAnnotation;

    if (annotation == null) return;

    switch (widget.controller.currentAnnotation.runtimeType) {
      case ShapeAnnotation:
        (annotation as ShapeAnnotation).add(normalizedPosition);
        widget.controller.updateView();
        break;
      case TextAnnotation:
        showTextAnnotationDialog(
          context: context,
          relativePosition: normalizedPosition,
          controller: widget.controller,
          visualImageSize: boundarySize,
        );
        break;
      case PolygonAnnotation:
        log(
          'Position: ${normalizedPosition.dx},${normalizedPosition.dy}',
          name: 'ImageAnnotation',
        );
        break;
      default:
        break;
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
        onPanUpdate: (details) {
          if (!_editing) return;
          if (!widget.controller.isShape) return;

          _draw(details.localPosition);
        },
        onPanStart: _onDrawStart,
        onPanEnd: (details) {
          _onDrawEnd.call();
          widget.onDrawEnd?.call(details);
        },
        onPanCancel: _onDrawEnd,
        onTapDown: (details) {
          switch (widget.controller.annotationType) {
            case AnnotationType.polygon:
              if (!_drawingPolygon) {
                widget.controller.add(
                  PolygonAnnotation(
                    strokeWidth: widget.controller.strokeWidth,
                    color: widget.controller.color,
                  ),
                );
                _drawingPolygon = true;
                setState(() {});
              }
              break;
            default:
              _draw(details.localPosition);
              break;
          }
        },
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
