import 'package:flutter/material.dart';

class LimitedWordText extends StatelessWidget {
  final String text;
  final int maxChars;
  final TextStyle? style;

  const LimitedWordText({
    super.key,
    required this.text,
    required this.maxChars,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final truncatedText =
        text.length > maxChars ? '${text.substring(0, maxChars)}...' : text;
    return Text(
      truncatedText,
      style: style,
    );
  }
}
