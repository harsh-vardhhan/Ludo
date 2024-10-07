import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ArrowIconComponent extends PositionComponent {
  final IconData arrowIcon;
  final Paint borderPaint;

  ArrowIconComponent({
    required IconData icon,
    required double size,
    required Vector2 position, // Make position a required parameter
    Color borderColor = Colors.black,
  })  : arrowIcon = icon,
        borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 {
    this.size = Vector2.all(size); // Set the size of the component
    this.position = position; // Set the position
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Create a TextPainter to render the icon
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(arrowIcon.codePoint),
        style: TextStyle(
          fontSize: size.x, // Font size for the arrow
          color: borderPaint.color,
          fontFamily: arrowIcon.fontFamily, // Use the FontAwesome font
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Calculate the offset to center the text within the component
    double xOffset = (size.x - textPainter.width) / 2;
    double yOffset = (size.y - textPainter.height) / 2;

    // Center the arrow in the component
    canvas.save();
    canvas.translate(xOffset, yOffset);

    // Draw the arrow icon
    textPainter.paint(canvas, Offset.zero);

    // Restore the canvas
    canvas.restore();
  }

  @override
  void update(double dt) {
    // No update logic required for this static component
  }
}