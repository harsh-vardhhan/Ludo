import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class StarComponent extends PositionComponent {
  final double innerRadius; // Instance variable for inner radius
  final double outerRadius; // Instance variable for outer radius
  final Paint borderPaint;

  // Constructor that initializes the size, innerRadius, and outerRadius
  StarComponent({
    required Vector2 size,
    required this.innerRadius, // Inner radius passed during component creation
    required this.outerRadius, // Outer radius passed during component creation
    Color borderColor = Colors.black,
  }) : borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.035 {
    this.size = size; // Set the size
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Create the star shape using the provided inner and outer radius
    Path starPath = createStarPath(innerRadius, outerRadius);

    // Center the star in the component's bounding box
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    // Draw the star with transparent fill and black border
    Paint fillPaint = Paint()..color = Colors.transparent;
    canvas.drawPath(starPath, fillPaint);
    canvas.drawPath(starPath, borderPaint); // Black border

    // Restore the canvas to its original state
    canvas.restore();
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