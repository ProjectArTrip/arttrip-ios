import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/utils/text/text_generator_impl.dart';
import 'package:flutter/material.dart';

class StyleBuilderImpl implements StyleBuilder {
  StyleBuilderImpl(this._style);

  final ArtTripText _style;

  @override
  TextGenerator build() => TextGeneratorImpl(_style);

  @override
  StyleBuilder color(Color color) => this.._style.color = color;

  @override
  StyleBuilder decoration(TextDecoration textDecoration) =>
      this.._style.textDecoration = textDecoration;

  @override
  StyleBuilder ellipsis(int? maxLine) => this.._style.ellipsis = maxLine;

  @override
  StyleBuilder fontSize(double fontSize) => this.._style.fontSize = fontSize;

  @override
  StyleBuilder fontWeight(FontWeight fontWeight) =>
      this.._style.fontWeight = fontWeight;

  @override
  StyleBuilder height(double height) => this.._style.height = height;

  @override
  StyleBuilder clearHeight() => this.._style.height = null;

  @override
  StyleBuilder letterSpacing(double letterSpacing) =>
      this.._style.letterSpacing = letterSpacing;

  @override
  StyleBuilder textAlign(TextAlign textAlign) =>
      this.._style.textAlign = textAlign;

  @override
  StyleBuilder textDecoration(TextDecoration textDecoration) =>
      this.._style.textDecoration = textDecoration;

  @override
  StyleBuilder fontFamily(String fontFamily) =>
      this.._style.fontFamily = fontFamily;
}
