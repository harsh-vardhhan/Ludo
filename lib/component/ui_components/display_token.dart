import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class DisplayToken extends PositionComponent with TapCallbacks {
  
  final Paint borderPaint; // Paint for the token's border
  final Paint fillPaint; // Paint for filling the token
  final Paint dropletFillPaint; // Paint for filling the droplet

  DisplayToken({
    required Vector2 position, // Initial position of the token
    required Vector2 size, // Size of the token
    required Color innerCircleColor, // Mandatory inner fill color
    Color borderColor = Colors.black, // Default border color
    Color dropletFillColor = Colors.white, // Default droplet fill color
  })  : borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.04
          ..color = borderColor,
        fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = innerCircleColor,
        dropletFillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = dropletFillColor,
        super(position: position, size: size);

  // Setter for innerCircleColor, updates the fillPaint color
  set innerCircleColor(Color color) {
    fillPaint.color = color; // Update the paint color when the color changes
  }

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
    canvas.drawCircle(center, smallerCircleRadius, fillPaint);
  }
}
