import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../ui_components/spot.dart'; // Replace with the actual path to your Spot component
import '../ui_components/arrow_icon_component.dart'; // Replace with the actual path to ArrowIconComponent
import '../ui_components/star_component.dart'; // Replace with the actual path to StarComponent


class YellowGridComponent extends PositionComponent {
  final bool showId;

  YellowGridComponent({
    required double size,
    this.showId = false,
  }) : super(
          size: Vector2.all(size),
        ) {
    _createGrid();
  }

  // Function to create the grid of rectangles
  void _createGrid() {
    double spacing = 0; // Vertical spacing between rectangles
    double columnSpacing = 0; // Horizontal spacing between columns

    int numberOfRows = 3;
    int numberOfColumns = 6;

    // Pre-calculate values used in the loop
    double sizeX = size.x;
    double sizeY = size.y;
    double halfSizeX = sizeX / 2;
    double halfSizeY = sizeY / 2;
    double strokeWidth = sizeX * 0.025;

    double arrowSize = sizeX * 0.50;
    Vector2 arrowPosition = Vector2(sizeX * 0.25, sizeX * 0.75);
    TextPaint textPaint = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: sizeX * 0.4, // Adjust font size as needed
      ),
    );

    // Loop to create 6 columns of 3 squares each
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.white;
        if (row == 1 && col < 5 || row == 2 && col == 4) {
          color = Colors.yellow;
        }

        // Create the unique ID for this block
        String uniqueId = 'Y$col$row';

        var rectangle = Spot(
          uniqueId: uniqueId,
          position: Vector2(col * (sizeX + columnSpacing), row * (sizeY + spacing)),
          size: size,
          paint: Paint()..color = color,
          children: [
            // Border Rectangle
            RectangleComponent(
              size: size,
              paint: Paint()
                ..color = Colors.transparent // Keep interior transparent
                ..style = PaintingStyle.stroke // Set style to stroke
                ..strokeWidth = strokeWidth // Set border width
                ..color = Colors.black, // Set border color to black
              children: [
                if (row == 0 && col == 3)
                  StarComponent(
                    size: size * 0.90,
                    position: Vector2(size.x * 0.05, size.x * 0.05),
                  ),
                if (col == 5 && row == 1)
                  ArrowIconComponent(
                    point: 'west', // Set direction
                    size: arrowSize, // Set the desired size
                    position: arrowPosition,
                    fillColor:
                        Colors.yellow, // Set the fill color for the triangle
                  ),
                // Add the unique ID as a text label at the center
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(halfSizeX, halfSizeY),
                    anchor: Anchor.center,
                    textRenderer: textPaint,
                  ),
              ],
            ),
          ],
        );
        add(rectangle);
      }
    }
  }
}