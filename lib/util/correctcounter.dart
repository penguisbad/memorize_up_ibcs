import 'package:flutter/material.dart';
import 'package:memorize_up/util/colors.dart' as colors;

class CorrectCounter extends StatelessWidget {

  final int n;

  const CorrectCounter({super.key, required this.n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            color: index < n ? colors.correctColor : Colors.transparent,
            border: index < n ? null : Border.all(color: Colors.white60),
            shape: BoxShape.circle
          ),
        ),
      ))
    );
  }

}