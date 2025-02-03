import 'dart:ui';

Offset convertToRelativePosition({
  required Offset point,
  required Size originalImageSize,
  required Size visualImageSize,
}) {
  final double scaleX = originalImageSize.width / visualImageSize.width;
  final double scaleY = originalImageSize.height / visualImageSize.height;

  return Offset(
    point.dx * scaleX,
    point.dy * scaleY,
  );
}

Offset convertToRenderPosition({
  required Offset relativePoint,
  required Size originalImageSize,
  required Size visualImageSize,
}) {
  final double scaleX = visualImageSize.width / originalImageSize.width;
  final double scaleY = visualImageSize.height / originalImageSize.height;

  return Offset(
    relativePoint.dx * scaleX,
    relativePoint.dy * scaleY,
  );
}
