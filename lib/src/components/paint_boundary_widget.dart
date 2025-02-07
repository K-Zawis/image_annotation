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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeFontSizes);
  }

  void _initializeFontSizes() {
    final boundarySize = _boundaryKey.currentContext?.size;
    if (boundarySize == null) return;

    for (final Annotation annotation in widget.controller.annotations) {
      if (annotation is DetectedAnnotation) {
        annotation.normalizedFontSize = convertToNormalizedFontSize(
          fontSize: widget.controller.fontSize,
          visualImageSize: boundarySize,
        );
      }
    }

    widget.controller.updateView();
  }

  void _draw(Offset position, {bool isText = false}) {
    Size? boundarySize = _boundaryKey.currentContext?.size;

    if (boundarySize == null || !_isWithinBounds(position, boundarySize)) {
      return;
    }

    final normalizedPosition = convertToNormalizedPosition(
      point: position,
      visualImageSize: boundarySize,
    );

    if (isText) {
      showTextAnnotationDialog(
        context: context,
        relativePosition: normalizedPosition,
        controller: widget.controller,
        visualImageSize: boundarySize,
      );
      return;
    }

    if (isText) {
      showTextAnnotationDialog(
        context: context,
        relativePosition: normalizedPosition,
        controller: widget.controller,
        visualImageSize: boundarySize,
      );
      return;
    }

    final Annotation? annotation = widget.controller.currentAnnotation;
    if (annotation == null) return;

    if (annotation is PolygonAnnotation || annotation is ShapeAnnotation) {
      (annotation as dynamic).add(normalizedPosition);
      widget.controller.updateCanvas();
    }
  }

  bool _isWithinBounds(Offset position, Size size) {
    return position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= size.width &&
        position.dy <= size.height;
  }

  void _handleDrawStart(_) {
    if (widget.controller.isPolygonalAnnotation) return;

    if (widget.controller.canEditCurrentAnnotation) {
      setState(() => _editing = true);
    }

    widget.onDrawStart?.call(_);
  }

  void _handleDrawEnd() {
    if (!widget.controller.canEditCurrentAnnotation) {
      setState(() => _editing = false);
    }
  }

  void _startPolylineDrawing(Offset position) {
    if (!widget.controller.polyDrawingActive) {
      widget.controller.add(ShapeAnnotation(
        AnnotationType.polyline,
        strokeWidth: widget.controller.strokeWidth,
        color: widget.controller.color,
      ));
      widget.controller.polylineDrawingActive = true;
    }
    _draw(position);
  }

  void _startPolygonDrawing(Offset position) {
    if (!widget.controller.polyDrawingActive) {
      widget.controller.add(PolygonAnnotation(
        strokeWidth: widget.controller.strokeWidth,
        color: widget.controller.color,
      ));
      widget.controller.polygonDrawingActive = true;
    }
    _draw(position);
    if (_polygonContainsThreePoints()) {
      widget.controller.polygonContainsThreePoints.value = true;
    }
  }

  bool _polygonContainsThreePoints() {
    final polygon = widget.controller.currentAnnotation as PolygonAnnotation?;
    if (polygon == null) return false;
    return polygon.normalizedPoints.length >= 3;
  }

  void _handleTap(Offset position) {
    switch (widget.controller.annotationType) {
      case AnnotationType.text:
        _draw(position, isText: true);
        break;
      case AnnotationType.polyline:
        _startPolylineDrawing(position);
        break;
      case AnnotationType.polygon:
        _startPolygonDrawing(position);
        break;
      default:
        break;
    }
  }

  List<Widget> _buildOverlayPoints(
    List<Offset> points,
    BoxConstraints constraints,
  ) {
    final Size size = Size(
      constraints.biggest.shortestSide,
      constraints.biggest.shortestSide,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return points.map((point) {
      final position = convertToRenderPosition(
        relativePoint: point,
        visualImageSize: size,
      );

      return Positioned(
        left: position.dx - 20,
        top: position.dy - 20,
        child: GestureDetector(
          onTap: () {
            log(
              "Point: $point",
              level: 800,
              name: 'D/AnnotationPaintBoundary',
              time: DateTime.now(),
            );

            final annotation =
                (widget.controller.currentAnnotation as ShapeAnnotation);

            annotation.remove(point);

            if (annotation.annotationType == AnnotationType.polygon &&
                !_polygonContainsThreePoints()) {
              widget.controller.polygonContainsThreePoints.value = false;
            }

            widget.controller.updateCanvas();
          },
          child: Container(
            height: 40,
            width: 40,
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceDim,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RepaintBoundary(
        key: _boundaryKey,
        child: GestureDetector(
          onPanCancel: _handleDrawEnd,
          onPanStart: _handleDrawStart,
          onPanUpdate: (details) {
            if (_editing &&
                widget.controller.isShapeAnnotation &&
                !widget.controller.isPolygonalAnnotation) {
              _draw(details.localPosition);
            }
          },
          onPanEnd: (details) {
            _handleDrawEnd.call();
            widget.onDrawEnd?.call(details);
          },
          onTapDown: (details) => _handleTap(details.localPosition),
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, child) {
              return Stack(
                children: [
                  CustomPaint(
                    foregroundPainter: AnnotationPainter(widget.controller),
                    child: LayoutBuilder(builder: (context, constrains) {
                      return Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: widget.controller.aspectRatio!,
                            child: SizedBox.expand(
                              child: widget.imageWidget,
                            ),
                          ),
                          if (widget.controller.polyDrawingActiveNotifier.value)
                            ..._buildOverlayPoints(
                              (widget.controller.currentAnnotation
                                      as ShapeAnnotation)
                                  .normalizedPoints,
                              constrains,
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
