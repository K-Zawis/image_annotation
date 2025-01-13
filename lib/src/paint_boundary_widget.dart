import 'package:flutter/material.dart';

import 'annotation_painter.dart';
import 'text_annotation.dart';
import 'annotation_option.dart';

class ImageAnnotationPaintBoundary extends StatelessWidget {
  final String imagePath;
  final Size imageSize;
  final Offset imageOffset;
  final Function(Offset) drawShape;
  final GestureDragStartCallback? onDrawStart;
  final GestureDragEndCallback? onDrawEnd;
  final List<List<Offset>> annotations;
  final List<TextAnnotation> textAnnotations;
  final AnnotationOption annotationType;

  const ImageAnnotationPaintBoundary({
    Key? key,
    required this.imagePath,
    required this.imageSize,
    required this.imageOffset,
    required this.drawShape,
    this.onDrawStart,
    this.onDrawEnd,
    required this.annotations,
    required this.textAnnotations,
    required this.annotationType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            width: imageSize.width,
            height: imageSize.height,
          ),
          Positioned(
            left: imageOffset.dx,
            top: imageOffset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                drawShape(details.localPosition);
              },
              onPanStart: onDrawStart,
              onPanEnd: onDrawEnd,
              child: CustomPaint(
                painter: AnnotationPainter(
                  annotations,
                  textAnnotations,
                  annotationType,
                ),
                size: imageSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
