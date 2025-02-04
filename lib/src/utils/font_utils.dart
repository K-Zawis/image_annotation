import 'dart:ui';

double convertToNormalizedFontSize({
  required double fontSize,
  required Size originalImageSize,
}) {
  return fontSize / originalImageSize.height;
}

double convertToRenderFontSize({
  required double relativePoint,
  required Size visualImageSize,
}) {
  return relativePoint * visualImageSize.height;
}