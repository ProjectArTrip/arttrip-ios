import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextGeneratorImpl implements TextGenerator {
  TextGeneratorImpl(this._style);

  final ArtTripText _style;

  @override
  TextStyle style() {
    return TextStyle(
        color: _style.color,
        fontSize: _style.fontSize.sp,
        fontWeight: _style.fontWeight,
        height: _style.height,
        letterSpacing: _style.letterSpacing.sp,
        decoration: _style.textDecoration,
        leadingDistribution: TextLeadingDistribution.even);
  }

  @override
  Widget text(String text) => Text(
        text,
        maxLines: _style.ellipsis,
        overflow: _style.ellipsis != null ? TextOverflow.ellipsis : null,
        textAlign: _style.textAlign,
        style: style(),
      );
}
