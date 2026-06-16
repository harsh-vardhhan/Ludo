import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ludo/managers/game_state.dart';
import 'package:ludo/models/player_team.dart';
import 'package:ludo/components/board/spot.dart';
import 'package:ludo/components/board/arrow_icon_component.dart';
import 'package:ludo/components/board/star_component.dart';

class LudoGridComponent extends PositionComponent {
  final PlayerTeam team;
  final double cellSize;
  final bool showId;

  LudoGridComponent({
    required this.team,
    required this.cellSize,
    this.showId = false,
  }) : super(
          size: Vector2.all(cellSize),
        ) {
    _createGrid();
  }

  void _createGrid() {
    double spacing = 0;
    double columnSpacing = 0;

    final isVertical = team == PlayerTeam.green || team == PlayerTeam.blue;
    final int numberOfColumns = isVertical ? 3 : 6;
    final int numberOfRows = isVertical ? 6 : 3;

    final double halfCellSize = cellSize / 2;
    final double textFontSize = cellSize * 0.4;
    final double strokeWidth = cellSize * 0.025;
    final double arrowSize = cellSize * 0.50;

    final TextPaint textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: textFontSize,
      ),
    );

    Color trackColor;
    switch (team) {
      case PlayerTeam.green:
        trackColor = GameState().green;
        break;
      case PlayerTeam.blue:
        trackColor = GameState().blue;
        break;
      case PlayerTeam.red:
        trackColor = GameState().red;
        break;
      case PlayerTeam.yellow:
        trackColor = GameState().yellow;
        break;
    }

    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.white;

        bool isColored = false;
        switch (team) {
          case PlayerTeam.green:
            isColored = (row > 0 && col == 1) || (row == 1 && col == 2);
            break;
          case PlayerTeam.blue:
            isColored = (col == 0 && row == 4) || (col == 1 && row < 5);
            break;
          case PlayerTeam.red:
            isColored = (row == 0 && col == 1) || (row == 1 && col > 0);
            break;
          case PlayerTeam.yellow:
            isColored = (row == 1 && col < 5) || (row == 2 && col == 4);
            break;
        }

        if (isColored) {
          color = trackColor;
        }

        final uniqueId = '${team.id}$col$row';

        bool hasStar = false;
        switch (team) {
          case PlayerTeam.green:
            hasStar = (col == 0 && row == 2);
            break;
          case PlayerTeam.blue:
            hasStar = (col == 2 && row == 3);
            break;
          case PlayerTeam.red:
            hasStar = (col == 2 && row == 2);
            break;
          case PlayerTeam.yellow:
            hasStar = (row == 0 && col == 3);
            break;
        }

        bool hasArrow = false;
        String arrowDirection = '';
        Vector2 arrowPosition = Vector2.zero();

        switch (team) {
          case PlayerTeam.green:
            if (col == 1 && row == 0) {
              hasArrow = true;
              arrowDirection = 'south';
              arrowPosition = Vector2(cellSize * 0.75, cellSize * 0.75);
            }
            break;
          case PlayerTeam.blue:
            if (col == 1 && row == 5) {
              hasArrow = true;
              arrowDirection = 'north';
              arrowPosition = Vector2(cellSize * 0.25, cellSize * 0.2);
            }
            break;
          case PlayerTeam.red:
            if (col == 0 && row == 1) {
              hasArrow = true;
              arrowDirection = 'east';
              arrowPosition = Vector2(cellSize * 0.75, cellSize * 0.25);
            }
            break;
          case PlayerTeam.yellow:
            if (col == 5 && row == 1) {
              hasArrow = true;
              arrowDirection = 'west';
              arrowPosition = Vector2(cellSize * 0.25, cellSize * 0.75);
            }
            break;
        }

        var rectangle = Spot(
          uniqueId: uniqueId,
          position: Vector2(col * (cellSize + columnSpacing), row * (cellSize + spacing)),
          size: Vector2.all(cellSize),
          paint: Paint()..color = color,
          children: [
            RectangleComponent(
              size: Vector2.all(cellSize),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = const Color(0xFF606676),
              children: [
                if (hasStar)
                  StarComponent(
                    size: Vector2.all(cellSize * 0.90),
                    position: Vector2(cellSize * 0.05, cellSize * 0.05),
                  ),
                if (hasArrow)
                  ArrowIconComponent(
                    point: arrowDirection,
                    size: arrowSize,
                    position: arrowPosition,
                    fillColor: trackColor,
                  ),
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(halfCellSize, halfCellSize),
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
