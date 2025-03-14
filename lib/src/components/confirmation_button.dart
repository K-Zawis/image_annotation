import 'dart:ui';

import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../utils/utils.dart' show OffsetClamping;
import '../models/models.dart' show PolygonAnnotation;

class DragConfirmationButtons extends StatefulWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final AnnotationController controller;
  final Size size;
  final Offset? position;
  final EdgeInsetsGeometry? padding;

  const DragConfirmationButtons({
    super.key,
    required this.controller,
    required this.size,
    this.onConfirm,
    this.onCancel,
    this.position,
    this.padding,
  });

  @override
  State<DragConfirmationButtons> createState() =>
      _DragConfirmationButtonsState();
}

class _DragConfirmationButtonsState extends State<DragConfirmationButtons> {
  static const Size widgetSize = Size(187, 26);
  late final EdgeInsets resolvedPadding;
  late final Rect clampLimits;
  late Offset position;
  bool moving = false;

  @override
  void initState() {
    Size sizeConstraint = Size(
      widget.size.width - widgetSize.width,
      widget.size.height - widgetSize.height,
    );

    resolvedPadding =
        (widget.padding ?? EdgeInsets.zero).resolve(TextDirection.ltr);

    final double leftLimit = resolvedPadding.left;
    final double rightLimit = sizeConstraint.width - resolvedPadding.right;
    final double topLimit = resolvedPadding.top;
    final double bottomLimit = sizeConstraint.height - resolvedPadding.bottom;

    clampLimits = Rect.fromLTRB(leftLimit, topLimit, rightLimit, bottomLimit);

    position = (widget.position ??
            Offset(
              (widget.size.width * 0.5) - widgetSize.width / 2,
              widget.size.height * 0.9,
            ))
        .clampFromRect(clampLimits);

    super.initState();
  }

  void _completePolyline() {
    widget.controller.polylineDrawingActive = false;
    widget.onConfirm?.call();
    widget.controller.updateView();
    widget.controller.updateCanvas();
  }

  void _cancelPolyline() {
    widget.controller.polylineDrawingActive = false;
    widget.controller.undoAnnotation();
    widget.onCancel?.call();
  }

  void _completePolygon() {
    final polygon = widget.controller.currentAnnotation as PolygonAnnotation?;
    polygon?.close();
    widget.controller.polygonDrawingActive = false;
    widget.controller.polygonContainsThreePoints.value = false;
    widget.controller.updateCanvas();
    widget.onConfirm?.call();
    widget.controller.updateView();
  }

  void _cancelPolygon() {
    widget.controller.polygonDrawingActive = false;
    widget.controller.polygonContainsThreePoints.value = false;
    widget.controller.undoAnnotation();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: ValueListenableBuilder(
        valueListenable: widget.controller.polyDrawingActiveNotifier,
        builder: (context, value, child) {
          if (!value) return const SizedBox.shrink();
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: BackdropFilter(
              // later make this optional
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: widgetSize.width,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceDim,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: colorScheme.surface,
                  ),
                ),
                child: Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable:
                          widget.controller.polygonContainsThreePoints,
                      builder: (context, value, child) {
                        return TextButton(
                          onPressed: !moving
                              ? widget.controller.polygonDrawingActive
                                  ? (value ? _completePolygon : null)
                                  : _completePolyline
                              : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: const Size(80, 24),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                            foregroundColor: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                          child: child!,
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          const Text("Finish"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 18,
                      width: 1,
                      child: VerticalDivider(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: !moving
                          ? widget.controller.polygonDrawingActive
                              ? _cancelPolygon
                              : _cancelPolyline
                          : null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(80, 24),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        foregroundColor:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          const Text("Cancel"),
                        ],
                      ),
                    ),
                    Draggable(
                      onDragUpdate: (details) {
                        final Offset newPosition = position + details.delta;

                        setState(() {
                          position = newPosition.clampFromRect(clampLimits);
                          moving = true;
                        });
                      },
                      onDragEnd: (details) => setState(() => moving = false),
                      feedback: const SizedBox(),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: colorScheme.outlineVariant,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
