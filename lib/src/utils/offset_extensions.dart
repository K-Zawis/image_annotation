import 'dart:ui';

extension OffsetClamping on Offset {
  Offset clamp(Size size) {
    return Offset(
      dx.clamp(0.0, size.width),
      dy.clamp(0.0, size.height),
    );
  }
}

extension OffsetNormalization on Offset {
  Offset toNormalized(Size referenceSize) => Offset(
        dx / referenceSize.width,
        dy / referenceSize.height,
      );

  Offset toAbsolute(Size referenceSize) => Offset(
        dx * referenceSize.width,
        dy * referenceSize.height,
      );
}
