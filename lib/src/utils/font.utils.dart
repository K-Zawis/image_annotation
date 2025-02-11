import 'dart:ui';

double convertToNormalizedFontSize({
  required double fontSize,
  required Size visualImageSize,
}) {
  return fontSize / visualImageSize.height; 
}

double convertToRenderFontSize({
  required double normalizedFontSize,
  required Size visualImageSize,
}) {
  return normalizedFontSize * visualImageSize.height;
}