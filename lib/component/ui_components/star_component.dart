import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StarComponent extends PositionComponent {
  final Paint borderPaint;
  StarComponent({
    required Vector2 position, // Initial position of the token
    required Vector2 size, // Size of the token
    Color borderColor = const Color(0xffD3DEDC),
  })  : borderPaint = Paint()..color = borderColor,
        super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final outerRadius = size.x / 2;
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, outerRadius, borderPaint);
  }
}
