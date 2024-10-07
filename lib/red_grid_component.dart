// red_grid_component.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'spot.dart'; // Replace with the actual path to your Spot component
import 'arrow_icon_component.dart'; // Replace with the actual path to ArrowIconComponent
import 'star_component.dart'; // Replace with the actual path to StarComponent

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

    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.white;
        if (row == 0 && col == 1 || row == 1 && col > 0) {
          color = Colors.red;
        }

        String uniqueId = 'R$col$row';

        var rectangle = Spot(
          uniqueId: uniqueId,
          position: Vector2(col * (size.x + columnSpacing), row * (size.x + spacing)),
          size: Vector2.all(size.x),
          paint: Paint()..color = color,
          children: [
            RectangleComponent(
              size: Vector2.all(size.x),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = size.x * 0.025
                ..color = Colors.black,
              children: [
                if (col == 2 && row == 2)
                  StarComponent(
                    size: size,
                    innerRadius: size.x * 0.24,
                    outerRadius: size.x * 0.48,
                  ),
                if (col == 0 && row == 1)
                  ArrowIconComponent(
                    icon: Icons.east,
                    size: size.x * 0.90,
                    position: Vector2(size.x * 0.05, size.x * 0.05),
                    borderColor: Colors.red,
                  ),
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(size.x / 2, size.x / 2),
                    anchor: Anchor.center,
                    textRenderer: TextPaint(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.x * 0.4,
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
