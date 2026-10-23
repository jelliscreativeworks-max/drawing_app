import 'package:flutter/material.dart';

class BoxIcon extends StatelessWidget {
  const BoxIcon({
    super.key,
    required this.color,
    this.size = 24.0,
    this.borderRadius = 4.0,
    this.border,
  });

  final Color color;
  final double size;
  final double borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: border,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
