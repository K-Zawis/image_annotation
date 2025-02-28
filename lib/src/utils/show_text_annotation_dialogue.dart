import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/models.dart' show TextAnnotation;
import 'font.utils.dart';

/// Displays a dialog for adding a text annotation.
void showTextAnnotationDialog({
  required BuildContext context,
  required Offset relativePosition,
  required AnnotationController controller,
  required Size visualImageSize,
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
                      visualImageSize: visualImageSize,
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
