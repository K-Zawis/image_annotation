import 'dart:ui';

double convertToNormalizedFontSize({
  required double fontSize,
  required Size visualImageSize,
}) {
  return fontSize / visualImageSize.height;
}

double convertToRenderFontSize({
  required double relativePoint,
  required Size visualImageSize,
}) {
  return relativePoint * visualImageSize.height;
}