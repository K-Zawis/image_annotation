import 'dart:ui';

Offset convertToNormalizedPosition({
  required Offset point,
  required Size visualImageSize,
}) {

  return Offset(
    point.dx / visualImageSize.width,
    point.dy / visualImageSize.height,
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
