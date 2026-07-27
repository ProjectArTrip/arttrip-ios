import 'dart:ui';

import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/utils/text/style_builder_impl.dart';

class ScaleTypeBuilderImpl extends ScaleTypeBuilder {
  ScaleTypeBuilderImpl(this._fontFamily) {
    _style = ArtTripText();
  }
  late ArtTripText _style;
  final String _fontFamily;

  @override
  StyleBuilder headline() {
    _style.fontFamily = _fontFamily;
    _style.fontWeight = FontWeight.w700;
    _style.fontSize = 20;
    _style.height = 28 / _style.fontSize;
    _style.letterSpacing = _style.fontSize * (-2 / 100);
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder title01Bold() {
    _style.fontWeight = FontWeight.w700;
    _style.fontSize = 18;
    _style.height = 20 / _style.fontSize;
    _style.letterSpacing = _style.fontSize * (-2 / 100);
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder title01Light() {
    _style.fontWeight = FontWeight.w300;
    _style.fontSize = 18;
    _style.height = 20 / _style.fontSize;
    _style.letterSpacing = _style.fontSize * (-2 / 100);
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder title02Bold() {
    _style.fontWeight = FontWeight.w700;
    _style.fontSize = 16;
    _style.height = 18 / _style.fontSize;
    _style.letterSpacing = _style.fontSize * (-2 / 100);
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder title02Light() {
    _style.fontWeight = FontWeight.w300;
    _style.fontSize = 16;
    _style.height = 18 / _style.fontSize;
    _style.letterSpacing = _style.fontSize * (-2 / 100);
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder body01Bold() {
    _style.fontWeight = FontWeight.w700;
    _style.fontSize = 14;
    _style.height = 16 / _style.fontSize;
    _style.letterSpacing = _style.fontSize * (-2 / 100);
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder body01Regular() {
    _style.fontWeight = FontWeight.w400;
    _style.fontSize = 14;
    _style.height = 20 / _style.fontSize;
    _style.letterSpacing = _style.fontSize * (-2 / 100);
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder body01Light() {
    _style.fontWeight = FontWeight.w300;
    _style.fontSize = 14;
    _style.height = 16 / _style.fontSize;
    _style.letterSpacing = _style.fontSize * (-2 / 100);
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder body02Bold() {
    _style.fontWeight = FontWeight.w700;
    _style.fontSize = 12;
    _style.letterSpacing = 0;
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder body02Regular() {
    _style.fontWeight = FontWeight.w400;
    _style.fontSize = 12;
    _style.letterSpacing = 0;
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder body02Light() {
    _style.fontWeight = FontWeight.w300;
    _style.fontSize = 12;
    _style.letterSpacing = 0;
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder body03Regular() {
    _style.fontWeight = FontWeight.w400;
    _style.fontSize = 11;
    _style.letterSpacing = 0;
    return StyleBuilderImpl(_style);
  }

  @override
  StyleBuilder font(double fontSize) {
    _style.fontWeight = FontWeight.w400;
    _style.fontSize = fontSize;
    _style.height = 16 / _style.fontSize;
    _style.letterSpacing = _style.fontSize * (-2 / 100);
    return StyleBuilderImpl(_style);
  }
}
