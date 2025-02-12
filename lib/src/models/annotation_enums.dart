/// Represents the different types of annotations that can be drawn on the image.
///
/// This enum is used by the [ImageAnnotation] widget to determine the type of annotation 
/// to be applied. The available options are:
/// - [line] : Draws a line annotation.
/// - [rectangle] : Draws a rectangle annotation.
/// - [oval] : Draws an oval annotation.
/// - [text] : Allows the user to add a text annotation to the image.
/// 
/// This enum ensures that only the valid annotation types are used with the [ImageAnnotation] widget.
enum AnnotationType {
  line,
  rectangle,
  oval,
  text,
}
