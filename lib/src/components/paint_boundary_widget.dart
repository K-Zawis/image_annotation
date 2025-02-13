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
  bool _drawingPolyline = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeFontSizes());
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

    final Annotation? annotation = widget.controller.currentAnnotation;
    if (annotation == null) return;

    if (annotation is PolygonAnnotation || annotation is ShapeAnnotation) {
      (annotation as dynamic).add(normalizedPosition);
      widget.controller.updateView();
    }
  }

  bool _isWithinBounds(Offset position, Size size) {
    return position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= size.width &&
        position.dy <= size.height;
  }

  void _handleDrawStart(_) {
    if (widget.controller.isPoly) return;

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

  void _startPolylineDrawing(Offset position) {
    if (!widget.controller.polyDrawingActive) {
      widget.controller.add(ShapeAnnotation(
        AnnotationType.polyline,
        strokeWidth: widget.controller.strokeWidth,
        color: widget.controller.color,
      ));
      setState(() => _drawingPolyline = true);
      widget.controller.polyDrawingActive = _drawingPolygon || _drawingPolyline;
    }
    _draw(position);
  }

  void _startPolygonDrawing(Offset position) {
    if (!widget.controller.polyDrawingActive) {
      widget.controller.add(PolygonAnnotation(
        strokeWidth: widget.controller.strokeWidth,
        color: widget.controller.color,
      ));
      _drawingPolygon = true;
      widget.controller.polyDrawingActive = _drawingPolygon || _drawingPolyline;
    }
    _draw(position);
    setState(() {});
  }

  void _completePolyline() {
    setState(() => _drawingPolyline = false);
    widget.controller.polyDrawingActive = _drawingPolygon || _drawingPolyline;
  }

  void _cancelPolyline() {
    widget.controller.undoAnnotation();
    setState(() => _drawingPolyline = false);
    widget.controller.polyDrawingActive = _drawingPolygon || _drawingPolyline;
  }

  void _completePolygon() {
    final polygon = widget.controller.currentAnnotation as PolygonAnnotation?;
    polygon?.close();
    setState(() => _drawingPolygon = false);
    widget.controller.polyDrawingActive = _drawingPolygon || _drawingPolyline;
  }

  void _cancelPolygon() {
    widget.controller.undoAnnotation();
    setState(() => _drawingPolygon = false);
    widget.controller.polyDrawingActive = _drawingPolygon || _drawingPolyline;
  }

  bool _polygonContainsThreePoints() {
    final polygon = widget.controller.currentAnnotation as PolygonAnnotation?;
    if (polygon == null) return false;
    return polygon.normalizedPoints.length >= 3;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Center(
            child: RepaintBoundary(
              key: _boundaryKey,
              child: GestureDetector(
                onPanCancel: _handleDrawEnd,
                onPanStart: _handleDrawStart,
                onPanUpdate: (details) {
                  if (_editing &&
                      widget.controller.isShape &&
                      !widget.controller.isPoly) {
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
                    return CustomPaint(
                      foregroundPainter: AnnotationPainter(widget.controller),
                      child: AspectRatio(
                        aspectRatio: widget.controller.aspectRatio!,
                        child: SizedBox.expand(
                          child: widget.imageWidget,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (widget.controller.polyDrawingActive)
          DraggableConfirmationButtons(
            onConfirm: _drawingPolygon
                ? (_polygonContainsThreePoints() ? _completePolygon : null)
                : _completePolyline,
            onCancel: _drawingPolygon ? _cancelPolygon : _cancelPolyline,
          ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     TextButton(
        //       onPressed: _drawingPolygon
        //           ? (_polygonContainsThreePoints() ? _completePolygon : null)
        //           : _completePolyline,
        //       child: Text(_drawingPolygon ? "Close Polygon" : "Done"),
        //     ),
        //     TextButton(
        //       onPressed: _drawingPolygon ? _cancelPolygon : _cancelPolyline,
        //       child: const Text("Cancel"),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class DraggableConfirmationButtons extends StatefulWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const DraggableConfirmationButtons({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<DraggableConfirmationButtons> createState() =>
      _DraggableConfirmationButtonsState();
}

class _DraggableConfirmationButtonsState
    extends State<DraggableConfirmationButtons> {
  Offset position = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: widget.onConfirm,
                  child: const Text("Finish"),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                position += details.delta;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              width: 60,
              height: 18,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
