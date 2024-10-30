import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class DisplayToken extends PositionComponent with TapCallbacks {
  Color topColor;
  Color sideColor;

  DisplayToken({
    required Vector2 position,
    required Vector2 size,
    required this.topColor,
    required this.sideColor,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Define the radius of the outer circle
    final outerRadius = size.x / 2;
    // Define the radius of the smaller inner circle
    final smallerCircle = outerRadius / 2.5; // Radius of the smaller circle
    final smallerCircleDepth = smallerCircle * 0.90;

    // Define the center of the circles
    final center = Offset(size.x / 2, size.y / 2);
    final centerShadow = Offset(size.x / 2, size.y / 1.65);
    final tokenShadow = Offset(size.x / 2, size.y / 1.5);
    final smallerCircleShadow = Offset(size.x / 2, size.y / 1.75);

    canvas.drawCircle(tokenShadow, outerRadius,
        Paint()..color = const Color(0xFF3C3D37).withOpacity(0.6));
    canvas.drawCircle(centerShadow, outerRadius,
        Paint()..color = sideColor); // Draw outer circle

    canvas.drawCircle(
        center, outerRadius, Paint()..color = topColor); // Draw border

    canvas.drawCircle(smallerCircleShadow, smallerCircleDepth,
        Paint()..color = const Color(0xFF3C3D37).withOpacity(0.7));
    canvas.drawCircle(center, smallerCircle, Paint()..color = Colors.white);
  }
}
