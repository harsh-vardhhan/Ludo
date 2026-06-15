import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum PointerDirection { left, right }

class DicePointer extends PositionComponent {
  final Paint paint;
  final PointerDirection direction;

  DicePointer({
    required double size,
    required this.paint,
    required this.direction,
    super.position,
  }) : super(size: Vector2.all(size));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final path = Path();

    if (direction == PointerDirection.left) {
      path
        ..moveTo(size.x, 0) // Right corner
        ..lineTo(0, size.y / 2) // Left corner (new "top")
        ..lineTo(size.x, size.y) // Bottom corner
        ..close();
    } else if (direction == PointerDirection.right) {
      path
        ..moveTo(0, 0) // Left corner
        ..lineTo(size.x, size.y / 2) // Right corner (new "top")
        ..lineTo(0, size.y) // Bottom corner
        ..close();
    }

    canvas.drawPath(path, paint);
  }
}
