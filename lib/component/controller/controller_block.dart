import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ControllerBlock extends PositionComponent {
  final Paint strokePaint;
  final double strokeWidth;
  final bool transparentRight;
  final bool transparentLeft;

  ControllerBlock({
    required Vector2 size, // Size of the rectangle
    required Vector2 position, // Position of the rectangle
    required Paint paint, // Fill paint of the rectangle
    this.strokeWidth = 4.0, // Width of the stroke
    this.transparentRight = false,
    this.transparentLeft = false,
    List<Component>? children, // Optional child components
  })  : strokePaint = Paint()
          ..color = paint.color.withOpacity(1.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
        super(
          size: size,
          position: position,
          children: children ?? [],
        );

  @override
  void render(Canvas canvas) {
    // Draw the filled rectangle
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect,
        Paint()..color = strokePaint.color.withOpacity(0)); // Transparent fill

    // Stroke paint for sides
    final transparentStrokePaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.0;

    // Draw stroke on sides, skipping the top if transparentTop is true
    if (transparentLeft) {
      canvas.drawLine(
          const Offset(0, 0), Offset(0, size.y), transparentStrokePaint);
    } else {
      canvas.drawLine(const Offset(0, 0), Offset(0, size.y), strokePaint);
    }
    if (transparentRight) {
      canvas.drawLine(
          Offset(size.x, 0), Offset(size.x, size.y), transparentStrokePaint);
    } else {
      canvas.drawLine(Offset(size.x, 0), Offset(size.x, size.y), strokePaint);
    }
    canvas.drawLine(const Offset(0, 0), Offset(size.x, 0), strokePaint); // Top
    canvas.drawLine(
        Offset(0, size.y), Offset(size.x, size.y), strokePaint); // Bottom
  }

  @override
  void update(double dt) {
    // Update logic if needed
  }
}

