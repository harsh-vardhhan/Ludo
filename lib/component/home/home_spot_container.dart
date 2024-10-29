import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'home_spot.dart';

class HomeSpotContainer extends RectangleComponent {
  HomeSpotContainer({
    required double size,
    required Vector2 position,
    required Paint homeSpotColor,
    required double radius,
  }) : super(
          size: Vector2.all(size),
          position: position,
          paint: Paint()..color = Colors.transparent,
        ) {
    _createHomeSpots(homeSpotColor, radius);
  }

  // Method to create home spots with unique IDs
  void _createHomeSpots(Paint homeSpotColor, double radius) {
    String colorCode = _getColorCode(homeSpotColor);

    // Pre-calculate positions for each slot
    final positions = [
      Vector2(0, 0), // Top-left
      Vector2(size.x - radius * 2, 0.0), // Top-right
      Vector2(0, size.y - radius * 2), // Bottom-left
      Vector2(size.x - radius * 2, size.y - radius * 2), // Bottom-right
    ];

    for (int slotNumber = 0; slotNumber < 4; slotNumber++) {
      String uniqueId = '$colorCode${slotNumber + 1}';

      HomeSpot homeSpot = HomeSpot(
        radius: radius,
        position: positions[slotNumber],
        paint: homeSpotColor,
        uniqueId: uniqueId, // Assign uniqueId to each HomeSpot
      );
      add(homeSpot);
    }
  }

  // Helper method to get the color code from the Paint object
  String _getColorCode(Paint paint) {
    Color color = paint.color;
    switch (color.value) {
      case 0xFFFF6969:
        return 'R';
      case 0xFF88C273:
        return 'G';
      case 0xFFA2D2DF:
        return 'B';
      case 0xffffeb3b:
        return 'Y';
      default:
        return 'U'; // For unknown colors
    }
  }
}
