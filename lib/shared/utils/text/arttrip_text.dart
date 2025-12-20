import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/shared/utils/text/scale_type_builder_impl.dart';
import 'package:flutter/material.dart';

class ArtTripText {
  Color color = AppColors.textPrimary;
  int? ellipsis;
  String? fontFamily;
  double fontSize = 14;
  FontWeight fontWeight = FontWeight.w400;
  double? height;
  double letterSpacing = 14 * (-2 / 100);
  TextAlign textAlign = TextAlign.start;

  TextDecoration? textDecoration;

  static ScaleTypeBuilder pretendard() =>
      ScaleTypeBuilderImpl(FontFamilyType.pretendard.fontName);
}

abstract class ScaleTypeBuilder {
  // headline
  StyleBuilder headline();

  // title
  StyleBuilder title01Bold();
  StyleBuilder title01Light();
  StyleBuilder title02Bold();
  StyleBuilder title02Light();

  // body
  StyleBuilder body01Bold();
  StyleBuilder body01Regular();
  StyleBuilder body01Light();
  StyleBuilder body02Bold();
  StyleBuilder body02Regular();
  StyleBuilder body02Light();
  StyleBuilder body03Regular();
}

abstract class StyleBuilder {
  TextGenerator build();

  StyleBuilder color(Color color);

  StyleBuilder fontFamily(String fontFamily);

  StyleBuilder decoration(TextDecoration textDecoration);

  StyleBuilder ellipsis(int? maxLine);

  StyleBuilder fontSize(double fontSize);

  StyleBuilder fontWeight(FontWeight fontWeight);

  StyleBuilder height(double height);

  StyleBuilder clearHeight();

  StyleBuilder letterSpacing(double letterSpacing);

  StyleBuilder textAlign(TextAlign textAlign);

  StyleBuilder textDecoration(TextDecoration textDecoration);
}

abstract class TextGenerator {
  Widget text(String text);

  TextStyle style();
}
