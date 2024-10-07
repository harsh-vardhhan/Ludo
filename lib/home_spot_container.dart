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

    for (int slotNumber = 1; slotNumber <= 4; slotNumber++) {
      String uniqueId = '$colorCode$slotNumber';

      HomeSpot homeSpot = HomeSpot(
        radius: radius,
        position: _getPositionForSlot(slotNumber, radius),
        paint: homeSpotColor,
        uniqueId: uniqueId, // Assign uniqueId to each HomeSpot
      );
      add(homeSpot);
    }
  }

  // Method to get the position for each slot
  Vector2 _getPositionForSlot(int slotNumber, double radius) {
    switch (slotNumber) {
      case 1:
        return Vector2(0, 0); // Top-left
      case 2:
        return Vector2(size.x - radius * 2, 0.0); // Top-right
      case 3:
        return Vector2(0, size.y - radius * 2); // Bottom-left
      case 4:
        return Vector2(
            size.x - radius * 2, size.y - radius * 2); // Bottom-right
      default:
        return Vector2(0, 0); // Default position
    }
  }

  // Helper method to get the color code from the Paint object
  String _getColorCode(Paint paint) {
    Color color = paint.color;
    String colorCode;

    if (color.value == const Color(0xfff44336).value) {
      colorCode = 'R';
    } else if (color.value == const Color(0xff4caf50).value) {
      colorCode = 'G';
    } else if (color.value == const Color(0xff2196f3).value) {
      colorCode = 'B';
    } else if (color.value == const Color(0xffffeb3b).value) {
      colorCode = 'Y';
    } else {
      colorCode = 'U'; // For unknown colors
    }

    return colorCode;
  }
}
