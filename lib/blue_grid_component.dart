import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'spot.dart'; // Replace with the actual path to your Spot component
import 'arrow_icon_component.dart'; // Replace with the actual path to ArrowIconComponent
import 'star_component.dart'; // Replace with the actual path to StarComponent

class BlueGridComponent extends PositionComponent {
  final bool showId;

  BlueGridComponent({
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

    // Loop to create 3 columns of 6 squares each
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.white;
        if (col == 0 && row == 4 || col == 1 && row < 5) {
          color = Colors.blue;
        }

        // Create the unique ID for this block
        String uniqueId = 'B$col$row';

        var rectangle = Spot(
          uniqueId: uniqueId,
          position:
              Vector2(col * (size.x + columnSpacing), row * (size.x + spacing)),
          size: size,
          paint: Paint()..color = color,
          children: [
            // Border Rectangle
            RectangleComponent(
              size: size,
              paint: Paint()
                ..color = Colors.transparent // Keep interior transparent
                ..style = PaintingStyle.stroke // Set style to stroke
                ..strokeWidth = size.x * 0.025 // Set border width
                ..color = Colors.black, // Set border color to black
              children: [
                if (col == 2 && row == 3)
                  StarComponent(
                    size: size,
                    innerRadius: size.x * 0.24,
                    outerRadius: size.x * 0.48,
                  ),
                if (col == 1 && row == 5)
                  ArrowIconComponent(
                    icon: Icons.north,
                    size: size.x * 0.90,
                    position: Vector2(size.x * 0.05, size.x * 0.05),
                    borderColor: Colors.blue,
                  ),
                // Add the unique ID as a text label at the center
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(size.x / 2, size.x / 2),
                    anchor: Anchor.center,
                    textRenderer: TextPaint(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.x * 0.4, // Adjust font size as needed
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
