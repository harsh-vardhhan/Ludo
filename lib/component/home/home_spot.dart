import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HomeSpot extends CircleComponent {
  final String uniqueId;
  static final Paint borderPaint = Paint()
    ..color = Colors.transparent // Keep interior transparent
    ..style = PaintingStyle.stroke // Set to stroke for the border
    ..strokeWidth = 1.0 // Set border width
    ..color =Colors.transparent; // Set border color to black

  HomeSpot({
    required double radius,
    required Vector2 position,
    required Paint paint,
    required this.uniqueId, // Accept uniqueId
  }) : super(
          radius: radius,
          position: position,
          paint: paint,
          children: [
            // Add a child CircleComponent to draw the border
            CircleComponent(
              radius: radius,
              paint: borderPaint, // Reuse static border paint
            ),
          ],
        );
}