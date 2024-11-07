import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'home_plate.dart';

class Home extends RectangleComponent {
  Home({
    required double size,
    required Paint? paint,
    required Paint homeSpotColor,
    List<Component>? children,
  }) : super(
          size: Vector2.all(size),
          paint: paint ?? Paint(), // Default color
          children: [
            // Define border as a separate child component for the stroke
            RectangleComponent(
              size: Vector2.all(size),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0
                ..color =Colors.transparent,
            ),
            HomePlate(
              size: size / 1.5,
              position: Vector2.all(size / 2 - size / 3), // Simplified center calculation
              homeSpotColor: homeSpotColor,
            ),
          ],
        );

  // Updated method to set color with optional paintId
  @override
  void setColor(Color color, {Object? paintId}) {
    if (paint.color != color) { // Avoid unnecessary updates
      paint.color = color; // Change the paint color of the main rectangle
    }
  }
}
