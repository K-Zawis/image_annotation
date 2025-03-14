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
  State<AnnotationPaintBoundary> createState() => _AnnotationPaintBoundaryState();
}

class _AnnotationPaintBoundaryState extends State<AnnotationPaintBoundary> {
  final GlobalKey _boundaryKey = GlobalKey();
  RenderBox? renderBox;
  Size? boundarySize;
  bool _editing = true;
  bool _movingPoint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeFontSizes());
  }

  @override
  void didUpdateWidget(covariant AnnotationPaintBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeFontSizes());
  }

  // To access the [RenderBox] and [Size] of our [_boundaryKey] during build, we must
  // add a post frame callback here. This retrieves these details when they change and
  // stores them in global vars.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _getPaintBoundaryRenderBox(),
    );
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

    widget.controller.updateCanvas();
  }

  void _getPaintBoundaryRenderBox() {
    final BuildContext? boundaryContext = _boundaryKey.currentContext;
    if (boundaryContext == null) return;

    renderBox = boundaryContext.findRenderObject() as RenderBox;
    if (renderBox == null) return;

    boundarySize = renderBox!.size;
  }

  void _draw(Offset position, {bool isText = false}) {
    if (boundarySize == null) {
      return;
    }

    final clampedPosition = position.clamp(boundarySize!);
    final normalizedPosition = clampedPosition.toNormalized(boundarySize!);

    if (isText) {
      showTextAnnotationDialog(
        context: context,
        relativePosition: normalizedPosition,
        controller: widget.controller,
        visualImageSize: boundarySize!,
      );
      return;
    }

    if (isText) {
      showTextAnnotationDialog(
        context: context,
        relativePosition: normalizedPosition,
        controller: widget.controller,
        visualImageSize: boundarySize!,
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
    log(
      "Tap has been detected.",
      level: 800,
      name: 'D/PaintBoundaryWidget',
      time: DateTime.now(),
    );

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
  ) {
    if (renderBox == null || boundarySize == null) return [];

    final colorScheme = Theme.of(context).colorScheme;

    return points.asMap().entries.map((entry) {
      final int index = entry.key;
      final Offset point = entry.value;

      final Offset position = point.toAbsolute(boundarySize!);

      return Positioned(
        left: position.dx - 20,
        top: position.dy - 20,
        child: GestureDetector(
          onTap: () {
            final annotation =
                widget.controller.currentAnnotation as ShapeAnnotation;

            annotation.remove(point);

            if (annotation.annotationType == AnnotationType.polygon &&
                !_polygonContainsThreePoints()) {
              widget.controller.polygonContainsThreePoints.value = false;
            }

            widget.controller.updateCanvas();
          },
          onPanStart: (_) => setState(() => _movingPoint = true),
          onPanEnd: (_) => setState(() => _movingPoint = false),
          onPanCancel: () => setState(() => _movingPoint = false),
          onPanUpdate: (details) {
            final position = renderBox!.globalToLocal(details.globalPosition);
            final clampedPosition = (position).clamp(boundarySize!);
            final normalizedPosition =
                clampedPosition.toNormalized(boundarySize!);

            final annotation =
                widget.controller.currentAnnotation as ShapeAnnotation;

            annotation.replaceAt(index, point: normalizedPosition);

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
                child: Center(
                  child: Container(
                    width: widget.controller.strokeWidth,
                    height: widget.controller.strokeWidth,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
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
          onPanEnd: (_) {
            _handleDrawEnd.call();
            widget.onDrawEnd?.call(_);
          },
          onTapUp: (details) =>
              _movingPoint ? null : _handleTap(details.localPosition),
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, child) {
              return Stack(
                children: [
                  CustomPaint(
                    foregroundPainter: AnnotationPainter(widget.controller),
                    child: AspectRatio(
                      aspectRatio: widget.controller.aspectRatio!,
                      child: SizedBox.expand(
                        child: widget.imageWidget,
                      ),
                    ),
                  ),
                  if (widget.controller.polyDrawingActiveNotifier.value)
                    ..._buildOverlayPoints(
                      (widget.controller.currentAnnotation as ShapeAnnotation)
                          .normalizedPoints,
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
