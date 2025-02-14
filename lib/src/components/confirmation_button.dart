import 'dart:ui';

import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';

class DragConfirmationButtons extends StatefulWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final AnnotationController controller;
  final Size size;

  const DragConfirmationButtons({
    super.key,
    required this.controller,
    required this.size,
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<DragConfirmationButtons> createState() =>
      _DragConfirmationButtonsState();
}

class _DragConfirmationButtonsState extends State<DragConfirmationButtons> {
  final Size widgetSize = const Size(187, 26);
  late Offset position;
  late Size clampSize;
  bool moving = false;

  @override
  void initState() {
    position = Offset(
      (widget.size.width * 0.5) - widgetSize.width / 2,
      widget.size.height * 0.9,
    );
    clampSize = Size(
      widget.size.width - widgetSize.width,
      widget.size.height - widgetSize.height,
    );
    super.initState();
  }

  void _completePolyline() {
    widget.controller.polylineDrawingActive = false;
    widget.onConfirm?.call();
    widget.controller.updateView();
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
    widget.controller.updateCanvas();
    widget.onConfirm?.call();
    widget.controller.updateView();
  }

  void _cancelPolygon() {
    widget.controller.polygonDrawingActive = false;
    widget.controller.undoAnnotation();
    widget.onCancel?.call();
  }

  bool _polygonContainsThreePoints() {
    final polygon = widget.controller.currentAnnotation as PolygonAnnotation?;
    if (polygon == null) return false;
    return polygon.normalizedPoints.length >= 3;
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
                    ListenableBuilder(
                      listenable: widget.controller.uiBuildNotifier,
                      builder: (context, child) {
                        return TextButton(
                          onPressed: !moving
                              ? widget.controller.polygonDrawingActive
                                  ? (_polygonContainsThreePoints()
                                      ? _completePolygon
                                      : null)
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
                            foregroundColor:
                                colorScheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color:
                                    colorScheme.onSurfaceVariant.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              const Text("Finish"),
                            ],
                          ),
                        );
                      }
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
                            colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 16,
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          const Text("Cancel"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onPanUpdate: (details) {
                        final Offset newPosition = position + details.delta;

                        setState(() {
                          position = Offset(
                            newPosition.dx.clamp(0.0, clampSize.width),
                            newPosition.dy.clamp(0.0, clampSize.height),
                          );
                          moving = true;
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          moving = false;
                        });
                      },
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: colorScheme.outlineVariant,
                      ),
                    ),
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
