import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'annotation.module.dart';
import 'annotation_enums.module.dart';

/// Represents a text annotation, which consists of a normalized position, a text
/// string, and a normalized font size.
///
/// This class is used to store and manage text annotations, ensuring they
/// scale properly when the image is resized.
///
/// @see
/// [Annotation]
class TextAnnotation extends Annotation {
  /// The normalized position of the text.
  ///
  /// The [Offset] points are values between `0` and `1`.
  final Offset _normalizedPosition;

  /// The text content of the annotation.
  final String text;

  /// The normalized font size.
  ///
  /// Defaults to `0.0`, but when rendered, it should be scaled
  /// according to the image's visual size.
  final double normalizedFontSize;

  /// Creates a [TextAnnotation] instance.
  /// - [normalizedPosition] : The normalized [Offset] of the text.
  ///   Values should be between `0` and `1`.
  /// - [text] : The annotation text content.
  /// - [normalizedFontSize] : The normalized font size.
  ///   Defaults to `0.0`.
  ///   Values should be between `0` and `1`.
  /// - [textColor] : The color of the text. Defaults to [Colors.black].
  TextAnnotation({
    required Offset normalizedPosition,
    required this.text,
    this.normalizedFontSize = 0.0,
    Color textColor = Colors.black,
  })  : assert(
          normalizedPosition.dx >= 0 && normalizedPosition.dx <= 1,
          'X coordinate is not normalized.',
        ),
        assert(
          normalizedPosition.dy >= 0 && normalizedPosition.dy <= 1,
          'Y coordinate is not normalized.',
        ),
        _normalizedPosition = normalizedPosition,
        super(AnnotationType.text, color: textColor);

  Offset get normalizedPosition => _normalizedPosition;

  @override
  void render(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: convertToRenderFontSize(
          normalizedFontSize: normalizedFontSize,
          visualImageSize: size,
        ),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final Offset renderPosition = convertToRenderPosition(
      relativePoint: normalizedPosition,
      visualImageSize: size,
    );

    final textPosition = Offset(
      renderPosition.dx - textPainter.width / 2,
      renderPosition.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textPosition);
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln("TextAnnotation(")
      ..writeln("  text: \"$text\",")
      ..writeln("  normalizedPosition: $_normalizedPosition,")
      ..writeln("  normalizedFontSize: $normalizedFontSize,")
      ..writeln("  color: $color,")
      ..write(")");
    return buffer.toString();
  }
}
