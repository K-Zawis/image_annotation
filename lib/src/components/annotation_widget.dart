import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'paint_boundary_widget.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';

/// A widget that enables users to annotate images with shapes and text.
///
/// Sever constructors are provided for the various ways that an image can be
/// specified:
///
///   * [ImageAnnotation.asset], for using images obtained from an [AssetBundle].
///   * [ImageAnnotation.network], for using images obtained from a URL.
///   * [ImageAnnotation.file], for using an image obtained from a [File].
///   * [ImageAnnotation.memory], for using an image obtained from a [Uint8List].
///
/// You may also pass in your own [Image] widget if you wish.
///
/// This widget supports line, rectangle, oval shape annotations,
/// and text annotations. It provides gesture callbacks for drawing interactions
/// and allows customization based on annotation type.
///
/// ## Example
///
/// ```dart
/// import 'dart:developer';
///
/// import 'package:flutter/material.dart';
/// import 'package:image_annotation/image_annotation.dart';
///
/// class ImageAnnotationPage extends StatelessWidget {
///   final String imagePath;
///
///  ImageAnnotationPage({
///    required this.imagePath,
///    super.key,
///  });
///
///   @override
///   Widget build(BuildContext context) {
///     return ImageAnnotation.asset(
///       imagePath,
///       annotationType: AnnotationOption.rectangle,
///       onDrawStart:(details) => log(
///         "onDrawStart: ${details.localPosition.toString()}",
///         level: 800,
///         name: 'INFO',
///       ),
///       onDrawEnd: (details) => log(
///         "onDrawEnd: ${details.localPosition.toString()}",
///         level: 800,
///         name: 'INFO',
///       ),
///     );
///   }
/// }
/// ```
///
/// Use the [annotationType] parameter to specify the type of annotation to apply.
/// Gesture callbacks [onDrawStart] and [onDrawEnd] can be used to handle annotation events.
class ImageAnnotation extends StatefulWidget {
  /// Image widget used for annotations.
  final Image imageWidget;

  /// Type of annotation to apply (for example: [AnnotationType.rectangle] or
  /// [AnnotationType.text]).
  final AnnotationType annotationType;

  /// Callback triggered when [onPanStart] fires.
  ///
  /// When [finalizeOnRelease] is enabled, you will recieve the screen start position of the
  /// shape annotation.
  final GestureDragStartCallback? onDrawStart;

  /// Callback triggered when [onPadEnd] fires.
  ///
  /// When [finalizeOnRelease] is enabled, you will recieve the screen end position of the
  /// shape annotation.
  final GestureDragEndCallback? onDrawEnd;

  /// Color of the current [Annotation]
  ///
  /// Modifiable only using the [AnnotationController]
  final Color? color;

  /// Stroke width of the current [ShapeAnnotation]
  ///
  /// Modifiable only using the [AnnotationController]
  final double? strokeWidth;

  /// Font size of the current [TextAnnotation]
  ///
  /// Modifiable only using the [AnnotationController]
  final double? fontSize;

  /// Whether the [ShapeAnnotation] is considered complete immedietly after drawing.
  ///
  /// Will cause [ShapeAnnotation] to be added to [_controller.annotations] when onPanStart is fired.
  ///
  /// Default behaviour sets this to false.
  final bool finalizeOnRelease;

  /// Whether annotations are limited to a certain max number.
  ///
  /// null means no limit
  final int? annotationLimit;

  /// Optional custom UI builder.
  ///
  /// Allows users to create their own UI using the
  /// [AnnotationController] and image annotating widget.
  ///
  /// Note: Disables default gesture controls.
  final Widget Function(
    BuildContext context,
    AnnotationController controller,
    Widget paintBoundary,
  )? builder;

  /// Optional custom loading builder when [AnnotationController.hasLoadedSize] is false
  ///
  /// Defaults to a 45x45 [CircularProgressIndicator].
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Optional list of detected annotation objects
  ///
  /// This is used for adding initial annotations when using an object detection model.
  final List<DetectedAnnotation>? detectedAnnotations;

  const ImageAnnotation({
    super.key,
    required this.imageWidget,
    required this.annotationType,
    this.onDrawStart,
    this.onDrawEnd,
    this.builder,
    this.loadingBuilder,
    this.color,
    this.strokeWidth,
    this.fontSize,
    this.finalizeOnRelease = false,
    this.annotationLimit,
    this.detectedAnnotations,
  })  : assert(strokeWidth == null || strokeWidth > 0.0),
        assert(fontSize == null || fontSize > 0.0);

  ImageAnnotation.network(
    String src, {
    super.key,
    required this.annotationType,
    this.onDrawStart,
    this.onDrawEnd,
    this.builder,
    this.loadingBuilder,
    this.color,
    this.strokeWidth,
    this.fontSize,
    this.finalizeOnRelease = false,
    this.annotationLimit,
    this.detectedAnnotations,
  })  : imageWidget = Image.network(
          src,
          fit: BoxFit.fill,
        ),
        assert(strokeWidth == null || strokeWidth > 0.0),
        assert(fontSize == null || fontSize > 0.0);

  ImageAnnotation.asset(
    String name, {
    super.key,
    required this.annotationType,
    this.onDrawStart,
    this.onDrawEnd,
    this.builder,
    this.loadingBuilder,
    this.color,
    this.strokeWidth,
    this.fontSize,
    this.finalizeOnRelease = false,
    this.annotationLimit,
    this.detectedAnnotations,
  })  : imageWidget = Image.asset(
          name,
          fit: BoxFit.fill,
        ),
        assert(strokeWidth == null || strokeWidth > 0.0),
        assert(fontSize == null || fontSize > 0.0);

  ImageAnnotation.file(
    File file, {
    super.key,
    required this.annotationType,
    this.onDrawStart,
    this.onDrawEnd,
    this.builder,
    this.loadingBuilder,
    this.color,
    this.strokeWidth,
    this.fontSize,
    this.finalizeOnRelease = false,
    this.annotationLimit,
    this.detectedAnnotations,
  })  : assert(
          !kIsWeb,
          'ImageAnnotation.file is not supported on Flutter Web. '
          'Consider using either Image.asset or Image.network instead.',
        ),
        imageWidget = Image.file(
          file,
          fit: BoxFit.fill,
        ),
        assert(strokeWidth == null || strokeWidth > 0.0),
        assert(fontSize == null || fontSize > 0.0);

  ImageAnnotation.memory(
    Uint8List bytes, {
    super.key,
    required this.annotationType,
    this.onDrawStart,
    this.onDrawEnd,
    this.builder,
    this.loadingBuilder,
    this.color,
    this.strokeWidth,
    this.fontSize,
    this.finalizeOnRelease = false,
    this.annotationLimit,
    this.detectedAnnotations,
  })  : imageWidget = Image.memory(
          bytes,
          fit: BoxFit.fill,
        ),
        assert(strokeWidth == null || strokeWidth > 0.0),
        assert(fontSize == null || fontSize > 0.0);

  @override
  State<ImageAnnotation> createState() => _ImageAnnotationState();
}

class _ImageAnnotationState extends State<ImageAnnotation> {
  /// Controller for handling events.
  late final AnnotationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnnotationController(
      widget.annotationType,
      color: widget.color,
      strokeWidth: widget.strokeWidth,
      fontSize: widget.fontSize,
      annotationLimit: widget.annotationLimit,
      finalizeOnRelease: widget.finalizeOnRelease,
    );

    _controller.loadImageSize(
      widget.imageWidget.image,
    );

    widget.detectedAnnotations?.forEach(
      (annotation) => _controller.add(annotation),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDrawStartWithFinalize(DragStartDetails details) {
    if (_controller.annotationType != AnnotationType.text) {
      _controller.add(
        ShapeAnnotation(
          _controller.annotationType,
          color: _controller.color,
          strokeWidth: _controller.strokeWidth,
        ),
      );
    }
    widget.onDrawStart?.call(details);
  }

  void completePolyline() =>
      setState(() => _controller.drawingPolyline = false);

  void cancelPolyline() {
    _controller.undoAnnotation();
    setState(() => _controller.drawingPolyline = false);
  }

  void completePolygon() {
    final polygon = _controller.currentAnnotation as PolygonAnnotation?;
    polygon?.close();
    setState(() => _controller.drawingPolygon = false);
  }

  void cancelPolygon() {
    _controller.undoAnnotation();
    setState(() => _controller.drawingPolygon = false);
  }

  bool _polygonContainsThreePoints() {
    final polygon = _controller.currentAnnotation as PolygonAnnotation?;
    if (polygon == null) return false;
    return polygon.normalizedPoints.length >= 3;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ValueListenableBuilder<bool>(
          valueListenable: _controller.hasLoadedSizeNotifier,
          builder: (context, hasLoadedSize, child) {
            if (!hasLoadedSize) {
              return widget.loadingBuilder != null
                  ? widget.loadingBuilder!(context)
                  : const Center(
                      child: SizedBox(
                        height: 45,
                        width: 45,
                        child: CircularProgressIndicator(),
                      ),
                    );
            }

            final annotationBoundary = AnnotationPaintBoundary(
              imageWidget: widget.imageWidget,
              controller: _controller,
              onDrawEnd: widget.onDrawEnd,
              onDrawStart: _controller.finalizeOnRelease
                  ? _handleDrawStartWithFinalize
                  : widget.onDrawStart,
            );

            return widget.builder != null
                ? widget.builder!(
                    context,
                    _controller,
                    annotationBoundary,
                  )
                : GestureDetector(
                    onLongPress: _controller.clearAnnotations,
                    onDoubleTap: _controller.undoAnnotation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: annotationBoundary,
                        ),
                        if (_controller.polyDrawingActive)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: _controller.drawingPolygon
                                      ? (_polygonContainsThreePoints()
                                          ? completePolygon
                                          : null)
                                      : completePolyline,
                                  child: const Text("Close Polygon"),
                                ),
                                TextButton(
                                  onPressed: _controller.drawingPolygon
                                      ? cancelPolygon
                                      : cancelPolyline,
                                  child: const Text("Cancel"),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
          },
        );
      },
    );
  }
}
