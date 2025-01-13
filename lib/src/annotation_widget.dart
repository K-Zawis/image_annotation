import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'annotation_action.dart';
import 'paint_boundary_widget.dart';
import 'annotation_controller.dart';
import 'annotation_option.dart';
import 'text_annotation.dart';

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

  /// Callback triggered when drawing starts.
  final GestureDragStartCallback? onDrawStart;

  /// Callback triggered when drawing ends.
  final GestureDragEndCallback? onDrawEnd;

  /// Optional custom UI builder. Allows users to create their own UI using the
  /// [ImageAnnotationController] and image annotating widget.
  final Widget Function(
    BuildContext context,
    ImageAnnotationController controller,
    Widget imageChild,
  )? builder;

  const ImageAnnotation({
    super.key,
    required this.imagePath,
    required this.annotationType,
    this.onDrawStart,
    this.onDrawEnd,
    this.builder,
  });

  @override
  State<ImageAnnotation> createState() => _ImageAnnotationState();
}

class _ImageAnnotationState extends State<ImageAnnotation> {
  /// Stores all annotations as lists of points.
  List<List<Offset>> annotations = [];

  /// Points for the current annotation being drawn.
  List<Offset> currentAnnotation = [];

  /// Stores text annotations with position and styling details.
  List<TextAnnotation> textAnnotations = [];

  /// Dimensions of the image to be annotated.
  Size? imageSize;

  /// Offset of the image's top-left corner relative to the widget.
  Offset? imageOffset;

  /// Controller for handling events.
  late final ImageAnnotationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImageAnnotationController(_handleControllerAction);
    loadImageSize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleControllerAction(AnnotationAction action) {
    switch (action) {
      case AnnotationAction.undo:
        clearLastAnnotation();
        break;
      case AnnotationAction.clear:
        clearAllAnnotations();
        break;
      case AnnotationAction.finish:
        startNewAnnotation();
        break;
    }
  }

  /// Loads the image dimensions asynchronously and sets [imageSize].
  void loadImageSize() async {
    final image = Image.asset(widget.imagePath);
    final completer = Completer<ui.Image>();

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );

    final loadedImage = await completer.future;

    if (!mounted) return;

    setState(() {
      imageSize = calculateImageSize(loadedImage);
    });
  }

  /// Calculates the size of the image while maintaining its aspect ratio.
  Size calculateImageSize(ui.Image image) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final imageRatio = image.width / image.height;
    final screenRatio = screenWidth / screenHeight;

    double width;
    double height;

    if (imageRatio > screenRatio) {
      width = screenWidth;
      height = screenWidth / imageRatio;
    } else {
      height = screenHeight;
      width = screenHeight * imageRatio;
    }

    return Size(width, height);
  }

  /// Calculates the position of the image relative to the widget.
  void calculateImageOffset() {
    if (imageSize == null) return;

    final imageWidget = context.findRenderObject() as RenderBox?;

    final imagePosition = imageWidget?.localToGlobal(Offset.zero);
    final widgetPosition =
        (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero);

    final offsetX = imagePosition!.dx - widgetPosition.dx;
    final offsetY = imagePosition.dy - widgetPosition.dy;

    setState(() {
      imageOffset = Offset(offsetX, offsetY);
    });
  }

  /// Initializes a new annotation path.
  void startNewAnnotation() {
    setState(() {
      currentAnnotation = [];
      annotations.add(currentAnnotation);
    });
  }

  /// Updates the current annotation path with the given [position].
  void drawShape(Offset position) {
    if (position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= imageSize!.width &&
        position.dy <= imageSize!.height) {
      setState(() {
        currentAnnotation.add(position);
      });
    }
  }

  /// Adds a text annotation at the specified [position].
  void addTextAnnotation(
    Offset position,
    String text,
    Color textColor,
    double fontSize,
  ) {
    setState(() {
      textAnnotations.add(TextAnnotation(
        position: position,
        text: text,
        textColor: textColor,
        fontSize: fontSize,
      ));
    });
  }

  /// Removes the last annotation (shape or text).
  void clearLastAnnotation() {
    setState(() {
      if (annotations.isNotEmpty) {
        annotations.removeLast();
      }
      if (textAnnotations.isNotEmpty) {
        textAnnotations.removeLast();
      }
    });
  }

  /// Clears all annotations.
  void clearAllAnnotations() {
    setState(() {
      annotations.clear();
      textAnnotations.clear();
      currentAnnotation = [];
    });
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
                  addTextAnnotation(localPosition, text, Colors.black, 16.0);
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateImageOffset();
    });

    if (imageSize == null || imageOffset == null) {
      // TODO: Implement an actual placeholder
      return const CircularProgressIndicator();
    }

    if (widget.builder != null) {
      return widget.builder!(
        context,
        _controller,
        ImageAnnotationPaintBoundary(
          imagePath: widget.imagePath,
          imageSize: imageSize!,
          imageOffset: imageOffset!,
          drawShape: drawShape,
          annotations: annotations,
          textAnnotations: textAnnotations,
          annotationType: widget.annotationType,
        ),
      );
    }

    return GestureDetector(
      onLongPress: clearAllAnnotations,
      onDoubleTap: clearLastAnnotation,
      onTapDown: (details) {
        if (widget.annotationType == AnnotationOption.text) {
          _showTextAnnotationDialog(context, details.localPosition);
        } else {
          startNewAnnotation();
        }
      },
      child: ImageAnnotationPaintBoundary(
          imagePath: widget.imagePath,
          imageSize: imageSize!,
          imageOffset: imageOffset!,
          drawShape: drawShape,
          annotations: annotations,
          textAnnotations: textAnnotations,
          annotationType: widget.annotationType,
        ),
    );
  }
}
