import 'package:flutter/material.dart';

class SizedColoredBox extends StatelessWidget {
  const SizedColoredBox({
    super.key,
    required this.color,
    this.width,
    this.height,
    this.child,
  });

  final Color color;
  final double? width;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      child: ColoredBox(
        color: color,
        child: child,
      ),
    );
  }
}