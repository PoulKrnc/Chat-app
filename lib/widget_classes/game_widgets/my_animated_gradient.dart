import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';
import 'package:pavli_text/utils/utils.dart';

class MyAnimatedGradient extends StatefulWidget {
  final Widget child;
  const MyAnimatedGradient({super.key, required this.child});

  @override
  _MyAnimatedGradientState createState() => _MyAnimatedGradientState();
}

class _MyAnimatedGradientState extends State<MyAnimatedGradient> {
  @override
  Widget build(BuildContext context) {
    return AnimateGradient(
        duration: const Duration(seconds: 5),
        primaryColors: isLightMode(context, lWidget: [
          Colors.blue.shade300,
          Colors.blue.shade400
        ], dWidget: [
          const Color.fromARGB(255, 133, 117, 205),
          const Color.fromARGB(255, 110, 87, 194)
        ]),
        secondaryColors: isLightMode(context, lWidget: [
          Colors.blue.shade500,
          Colors.blue.shade600
        ], dWidget: [
          const Color.fromARGB(255, 81, 58, 183),
          const Color.fromARGB(255, 76, 53, 177)
        ]),
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomRight,
        secondaryBegin: Alignment.bottomRight,
        secondaryEnd: Alignment.topLeft,
        child: widget.child);
  }
}
