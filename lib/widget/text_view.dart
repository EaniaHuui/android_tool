import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  const TextView(
    this.text, {
    Key? key,
    this.color,
    this.fontSize,
    this.textAlign,
  }) : super(key: key);

  final String text;
  final Color? color;
  final double? fontSize;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color ?? const Color(0xFF383838),
        fontSize: fontSize,
      ),
    );
  }
}
class SelectableTextView extends StatelessWidget {
  const SelectableTextView(
    this.text, {
    Key? key,
    this.color,
    this.fontSize,
    this.textAlign,
  }) : super(key: key);

  final String text;
  final Color? color;
  final double? fontSize;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color ?? const Color(0xFF383838),
        fontSize: fontSize,
      ),
    );
  }
}
