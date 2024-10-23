import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ArrowIconComponent extends PositionComponent {
  final Paint paint; // Paint for the triangle fill
  final String point; // Direction to point the triangle

  ArrowIconComponent({
    required this.point, // Accept the direction as a parameter
    required double size,
    required Vector2 position,
    Color fillColor = Colors.black, // Fill color for the triangle
  })  : paint = Paint()
          ..color = fillColor // Use the fill color
          ..style = PaintingStyle.fill,
        super() {
    this.size = Vector2.all(size); // Set the size of the component
    this.position = position; // Set the position
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Calculate the triangle points
    final path = Path();
    path.moveTo(size.x / 2, 0); // Top point
    path.lineTo(0, size.y); // Bottom left point
    path.lineTo(size.x, size.y); // Bottom right point
    path.close(); // Close the path to create the triangle

    // Save the canvas state
    canvas.save();

    // Rotate the canvas based on the specified direction
    switch (point.toLowerCase()) {
      case 'north':
        canvas.rotate(0); // 0 degrees
        break;
      case 'south':
        canvas.rotate(3.14159); // 180 degrees
        break;
      case 'east':
        canvas.rotate(1.5708); // 90 degrees
        break;
      case 'west':
        canvas.rotate(-1.5708); // -90 degrees
        break;
      default:
        // Optional: Handle invalid direction
        break;
    }

    // Draw the triangle using the fill color
    canvas.drawPath(path, paint); // Fill the triangle

    // Restore the canvas to its previous state
    canvas.restore();
  }

  @override
  void update(double dt) {
    // No update logic required for this static component
  }
}
