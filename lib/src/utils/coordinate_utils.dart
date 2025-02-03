import 'dart:ui';

Offset convertToRelativePosition({
  required Offset point,
  required Size originalImageSize,
}) {

  return Offset(
    point.dx / originalImageSize.width,
    point.dy / originalImageSize.height,
  );
}

Offset convertToRenderPosition({
  required Offset relativePoint,
  required Size visualImageSize,
}) {
  return Offset(
    relativePoint.dx * visualImageSize.width,
    relativePoint.dy * visualImageSize.height,
  );
}
