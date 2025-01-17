import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'paint_boundary_widget.dart';
import 'annotation_controller.dart';
import 'annotation_enums.dart';
import 'annotation_models.dart';

/// A widget that enables users to annotate images with shapes and text.
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
///     return ImageAnnotation(
///       imagePath: imagePath,
///       annotationType: AnnotationOption.rectangle,
///       sourceType: ImageSourceType.asset,
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
  /// Path to the image used for annotations.
  final String imagePath;

  /// Type of annotation to apply (for example: [AnnotationOption.rectangle] or
  /// [AnnotationOption.text]).
  final AnnotationOption annotationType;

  /// Specifies which source the [imagePath] uses
  final ImageSourceType sourceType;

  /// Padding around the image paint boundary
  final EdgeInsets padding;

  /// Callback triggered when drawing starts.
  final GestureDragStartCallback? onDrawStart;

  /// Callback triggered when drawing ends.
  final GestureDragEndCallback? onDrawEnd;

  /// Color of the annotations
  final Color? color;

  /// Stroke width of the current [ShapeAnnotation]
  final double? strokeWidth;

  /// Font size of the current [TextAnnotation]
  final double? fontSize;

  /// Whether the [ShapeAnnotation] is considered complete immedietly after drawing.
  ///
  /// Will cause [ShapeAnnotation] to be added to [_controller.annotations] when onPanStart is fired.
  ///
  /// Default behaviour sets this to false.
  final bool finalizeOnRelease;

  /// Optional custom UI builder.
  ///
  /// Allows users to create their own UI using the
  /// [ImageAnnotationController] and image annotating widget.
  ///
  /// Note: Disables default gesture controls.
  final Widget Function(
    BuildContext context,
    ImageAnnotationController controller,
    Widget paintBoundary,
  )? builder;

  /// Optional custom loading builder when [imageSize] or [imageOffset] are null
  ///
  /// Defaults to a 45x45 [CircularProgressIndicator].
  final Widget Function(BuildContext context)? loadingBuilder;

  const ImageAnnotation({
    super.key,
    required this.imagePath,
    required this.annotationType,
    required this.sourceType,
    this.padding = const EdgeInsets.all(8),
    this.onDrawStart,
    this.onDrawEnd,
    this.builder,
    this.loadingBuilder,
    this.color,
    this.strokeWidth,
    this.fontSize,
    this.finalizeOnRelease = false,
  })  : assert(strokeWidth == null || strokeWidth > 0.0),
        assert(fontSize == null || fontSize > 0.0),
        assert(
          sourceType != ImageSourceType.file || !kIsWeb,
          'ImageSourceType.file is not supported on the web.',
        );

  @override
  State<ImageAnnotation> createState() => _ImageAnnotationState();
}

class _ImageAnnotationState extends State<ImageAnnotation> {
  /// Controller for handling events.
  late final ImageAnnotationController _controller;

  /// Image widget based on [sourceType]
  late final Image _imageWidget;

  @override
  void initState() {
    super.initState();

    _controller = ImageAnnotationController(
      widget.annotationType,
      color: widget.color,
      strokeWidth: widget.strokeWidth,
      fontSize: widget.fontSize,
    );

    switch (widget.sourceType) {
      case ImageSourceType.asset:
        _imageWidget = Image.asset(
          widget.imagePath,
          fit: BoxFit.fill,
        );
        break;
      case ImageSourceType.file:
        _imageWidget = Image.file(
          File(widget.imagePath),
          fit: BoxFit.fill,
        );
        break;
      case ImageSourceType.network:
        _imageWidget = Image.network(
          widget.imagePath,
          fit: BoxFit.fill,
        );
        break;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadImageSize(
        _imageWidget.image,
        context,
        widget.padding,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Displays a dialog for adding a text annotation.
  void _showTextAnnotationDialog(
    BuildContext context,
    Offset localPosition,
  ) {
    String text = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Text Annotation'),
          content: TextField(
            onChanged: (value) {
              text = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (text.isNotEmpty) {
                  // Add the text annotation
                  _controller.add(
                    TextAnnotation(
                      position: localPosition,
                      text: text,
                      textColor: _controller.color,
                      fontSize: _controller.fontSize,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _handleDrawStartWithFinalize(DragStartDetails details) {
    if (_controller.annotationType != AnnotationOption.text) {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _controller.loadImageSize(
          _imageWidget.image,
          context,
          widget.padding,
        );

        return ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            if (!_controller.hasLoadedSize) {
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

            return widget.builder != null
                ? widget.builder!(
                    context,
                    _controller,
                    ImageAnnotationPaintBoundary(
                      imageWidget: _imageWidget,
                      controller: _controller,
                      onDrawEnd: widget.onDrawEnd,
                      onDrawStart: widget.finalizeOnRelease
                          ? _handleDrawStartWithFinalize
                          : widget.onDrawStart,
                    ),
                  )
                : GestureDetector(
                    onLongPress: _controller.clearAnnotations,
                    onDoubleTap: _controller.undoAnnotation,
                    onTapDown: (details) {
                      if (_controller.annotationType == AnnotationOption.text) {
                        _showTextAnnotationDialog(
                            context, details.localPosition);
                      } else if (!widget.finalizeOnRelease) {
                        _controller.add(
                          ShapeAnnotation(
                            _controller.annotationType,
                            color: _controller.color,
                            strokeWidth: _controller.strokeWidth,
                          ),
                        );
                      }
                    },
                    child: ImageAnnotationPaintBoundary(
                      imageWidget: _imageWidget,
                      controller: _controller,
                      onDrawEnd: widget.onDrawEnd,
                      onDrawStart: widget.finalizeOnRelease
                          ? _handleDrawStartWithFinalize
                          : widget.onDrawStart,
                    ),
                  );
          },
        );
      },
    );
  }
}
