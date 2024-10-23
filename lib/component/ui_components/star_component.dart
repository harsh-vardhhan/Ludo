import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class StarComponent extends PositionComponent {
  final Paint borderPaint;
  final Paint dropletFillPaint; // Paint for filling the droplet

  // Constructor that initializes the size, innerRadius, and outerRadius
  StarComponent({
    required Vector2 position, // Initial position of the token
    required Vector2 size, // Size of the token
    Color borderColor = Colors.black, // Default border color
    Color dropletFillColor = Colors.white, // Default droplet fill color
  })  : borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.04
          ..color = borderColor,
        dropletFillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = dropletFillColor,
        super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Define the radius of the outer circle
    final outerRadius = size.x / 2;
    // Define the radius of the smaller inner circle
    final smallerCircleRadius =
        outerRadius / 1.7; // Radius of the smaller circle

    // Define the center of the circles
    final center = Offset(size.x / 2, size.y / 2);

    // Draw the outer circle with white fill
    canvas.drawCircle(center, outerRadius,
        Paint()..color = Colors.white); // Draw outer circle
    canvas.drawCircle(center, outerRadius, borderPaint); // Draw border

    // Draw the smaller inner circle with the specified innerCircleColor
    canvas.drawCircle(center, smallerCircleRadius, borderPaint);
  }

  /// Creates a star shape with the specified inner and outer radius.
  /// Rotate the star so that one tip is at the top (90 degrees).
  Path createStarPath(double innerRadius, double outerRadius) {
    Path path = Path();
    double angleStep = pi / 5; // 5-pointed star
    double angleOffset = -pi / 2; // Offset to point one tip upwards

    for (int i = 0; i < 10; i++) {
      double radius = i.isEven ? outerRadius : innerRadius;
      double angle = angleStep * i + angleOffset;
      double x = radius * cos(angle);
      double y = radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void update(double dt) {
    // No update logic required for this static component
  }
}