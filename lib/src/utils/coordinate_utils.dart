import 'dart:ui';

Offset convertToImagePosition({
  required Offset viewPosition,
  required Size originalImageSize,
  required Size visualImageSize,
}) {
  final double scaleX = originalImageSize.width / visualImageSize.width;
  final double scaleY = originalImageSize.height / visualImageSize.height;

  return Offset(
    viewPosition.dx * scaleX,
    viewPosition.dy * scaleY,
  );
}

Offset convertToVisualPosition({
  required Offset point,
  required Size originalImageSize,
  required Size visualSize,
}) {
  final double scaleX = visualSize.width / originalImageSize.width;
  final double scaleY = visualSize.height / originalImageSize.height;

  return Offset(
    point.dx * scaleX,
    point.dy * scaleY,
  );
}
