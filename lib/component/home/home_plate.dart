import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'home_spot_container.dart';

class HomePlate extends RectangleComponent {
  // Constructor to initialize the square with size, position, and optional paint
  HomePlate({
    required double size,
    required Vector2 position,
    required Paint homeSpotColor,
  }) : super(
          size: Vector2.all(size),
          position: position,
          // First paint object for the fill (white color)
          paint: Paint()..color = Colors.white,
          children: [
            // Define border as a separate child component for the stroke
            RectangleComponent(
              size: Vector2.all(size),
              paint: Paint()
                ..color = Colors.transparent // Keep interior transparent
                ..style = PaintingStyle.stroke // Set style to stroke
                ..strokeWidth = 1.0 // Set border width
                ..color = Colors.black, // Set border color to black
            ),
            HomeSpotContainer(
              size: size / 1.5,
              position: position / 1.5,
              homeSpotColor: homeSpotColor,
              radius: size / 8,
            ),
          ],
        );
}