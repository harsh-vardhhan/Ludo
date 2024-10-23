// red_grid_component.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../ui_components/spot.dart'; // Replace with the actual path to your Spot component
import '../ui_components/arrow_icon_component.dart'; // Replace with the actual path to ArrowIconComponent
import '../ui_components/star_component.dart'; // Replace with the actual path to StarComponent

class RedGridComponent extends PositionComponent {
  final bool showId;

  RedGridComponent({
    required double size,
    this.showId = false,
  }) : super(
          size: Vector2.all(size),
        ) {
    _createGrid();
  }

  void _createGrid() {
    double spacing = 0;
    double columnSpacing = 0;

    int numberOfRows = 3;
    int numberOfColumns = 6;

    // Pre-calculate size-related values to avoid repeated calculations
    final double sizeX = size.x;
    final double halfSizeX = sizeX / 2;
    final double strokeWidth = sizeX * 0.025;
    final double arrowSize = sizeX * 0.50;
    final Vector2 arrowPosition = Vector2(sizeX * 0.75, sizeX * 0.25);
    final TextPaint textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: sizeX * 0.4,
      ),
    );

    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.white;
        if (row == 0 && col == 1 || row == 1 && col > 0) {
          color = Colors.red;
        }

        String uniqueId = 'R$col$row';

        var rectangle = Spot(
          uniqueId: uniqueId,
          position:
              Vector2(col * (sizeX + columnSpacing), row * (sizeX + spacing)),
          size: Vector2.all(sizeX),
          paint: Paint()..color = color,
          children: [
            RectangleComponent(
              size: Vector2.all(sizeX),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = Colors.black,
              children: [
                if (col == 2 && row == 2)
                  StarComponent(
                    size: size * 0.90,
                    position: Vector2(size.x * 0.05, size.x * 0.05),
                  ),
                if (col == 0 && row == 1)
                  ArrowIconComponent(
                    point: 'east', // Set direction
                    size: arrowSize, // Set the desired size
                    position: arrowPosition,
                    fillColor:
                        Colors.red, // Set the fill color for the triangle
                  ),
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(halfSizeX, halfSizeX),
                    anchor: Anchor.center,
                    textRenderer: textRenderer,
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
