import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../ui_components/spot.dart'; // Replace with the actual path to your Spot component
import '../ui_components/arrow_icon_component.dart'; // Replace with the actual path to ArrowIconComponent
import '../ui_components/star_component.dart'; // Replace with the actual path to StarComponent


class GreenGridComponent extends PositionComponent {
  final bool showId;

  GreenGridComponent({
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

    int numberOfRows = 6;
    int numberOfColumns = 3;

    // Pre-calculate size-related values
    double sizeX = size.x;
    double halfSizeX = sizeX / 2;
    double textFontSize = sizeX * 0.4;
    double strokeWidth = sizeX * 0.025;
    double arrowSize = sizeX * 0.90;
    double arrowPositionOffset = sizeX * 0.05;
    double starInnerRadius = sizeX * 0.24;
    double starOuterRadius = sizeX * 0.48;

    // Loop to create 3 columns of 6 squares each
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.white;
        if (row > 0 && col == 1 || row == 1 && col == 2) {
          color = Colors.green;
        }

        // Create the unique ID for this block
        String uniqueId = 'G$col$row';

        var rectangle = Spot(
          uniqueId: uniqueId,
          position: Vector2(col * (sizeX + columnSpacing), row * (sizeX + spacing)),
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
                if (col == 0 && row == 2)
                  StarComponent(
                    size: size,
                    innerRadius: starInnerRadius,
                    outerRadius: starOuterRadius,
                  ),
                if (col == 1 && row == 0)
                  ArrowIconComponent(
                    icon: Icons.south,
                    size: arrowSize,
                    position: Vector2(arrowPositionOffset, arrowPositionOffset),
                    borderColor: Colors.green,
                  ),
                // Add the unique ID as a text label at the center
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(halfSizeX, halfSizeX),
                    anchor: Anchor.center,
                    textRenderer: TextPaint(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: textFontSize, // Adjust font size as needed
                      ),
                    ),
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

