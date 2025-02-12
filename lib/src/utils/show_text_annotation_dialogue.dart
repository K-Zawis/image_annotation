import 'package:flutter/material.dart';
import 'package:image_annotation/src/utils/font_utils.dart';

import '../../image_annotation.dart';

/// Displays a dialog for adding a text annotation.
void showTextAnnotationDialog({
  required BuildContext context,
  required Offset relativePosition,
  required AnnotationController controller,
}) {
  final ThemeData theme = Theme.of(context);
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
          decoration: const InputDecoration().applyDefaults(
            theme.inputDecorationTheme,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (text.isNotEmpty) {
                // Add the text annotation
                controller.add(
                  TextAnnotation(
                    normalizedPosition: relativePosition,
                    text: text,
                    textColor: controller.color,
                    normalizedFontSize: convertToNormalizedFontSize(
                      fontSize: controller.fontSize,
                      originalImageSize: controller.originalImageSize!,
                    ),
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
