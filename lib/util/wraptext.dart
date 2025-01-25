import 'package:flutter/material.dart';

class WrapText extends StatelessWidget {

  final String text;
  final TextStyle style;
  final bool center;

  const WrapText({super.key, required this.text, required this.style, this.center = true});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(text, style: style, softWrap: true, textAlign:
      center ? TextAlign.center : TextAlign.start))
    ]);
  }

}