import 'dart:ui';

double convertToNormalizedFontSize({
  required double fontSize,
  required Size originalImageSize,
  required Size visualImageSize,
}) {
  // return fontSize / visualImageSize.height; // might need to find something else to calculate the normalized fontSize. a mix of original image and visual perhaps?
  double scaleFactor =
      (visualImageSize.height / originalImageSize.height).clamp(
    0.2,
    1.5,
  ); // Avoid extreme scaling
  return fontSize * scaleFactor;
}

double convertToRenderFontSize({
  required double normalizedFontSize,
  required Size originalImageSize,
  required Size visualImageSize,
}) {
  // return normalizedFontSize * visualImageSize.height;
  double scaleFactor =
      (visualImageSize.height / originalImageSize.height).clamp(
    0.2,
    1.5,
  );
  return normalizedFontSize / scaleFactor;
}
