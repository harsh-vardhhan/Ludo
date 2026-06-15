import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'home_spot.dart';

class HomeSpotContainer extends RectangleComponent {
  final String teamCode;

  HomeSpotContainer({
    required double size,
    required Vector2 position,
    required Paint homeSpotColor,
    required double radius,
    required this.teamCode,
  }) : super(
          size: Vector2.all(size),
          position: position,
          paint: Paint()..color = Colors.transparent,
        ) {
    _createHomeSpots(homeSpotColor, radius);
  }

  // Method to create home spots with unique IDs
  void _createHomeSpots(Paint homeSpotColor, double radius) {
    // Pre-calculate positions for each slot
    final positions = [
      Vector2(0, 0), // Top-left
      Vector2(size.x - radius * 2, 0.0), // Top-right
      Vector2(0, size.y - radius * 2), // Bottom-left
      Vector2(size.x - radius * 2, size.y - radius * 2), // Bottom-right
    ];

    for (int slotNumber = 0; slotNumber < 4; slotNumber++) {
      String uniqueId = '$teamCode${slotNumber + 1}';

      HomeSpot homeSpot = HomeSpot(
        radius: radius,
        position: positions[slotNumber],
        paint: homeSpotColor,
        uniqueId: uniqueId, // Assign uniqueId to each HomeSpot
      );
      add(homeSpot);
    }
  }
}
